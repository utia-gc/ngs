include { samplesheetToList } from 'plugin/nf-schema'

/**
 * Parse the input samplesheet.
 *
 * Validate and parse the input samplesheet with nf-schema `samplesheetToList`.
 * Wrangles the input samples into the format of channels expected by downstream processes.
 *
 * @take samplesheet File object to input samplesheet.
 * @emit List channel of samples of shape [ metadata, [ reads1 ], [ reads2 ] ] where reads2 is an empty file if no R2 file was supplied.
 */
workflow Parse_Samplesheet {
    take:
        samplesheet

    main:
        Channel
            // use nf-schema to handle samplesheet parsing
            .fromList(
                samplesheetToList(samplesheet, "${projectDir}/assets/schema_samplesheet.json")
            )
            /*
                Reshape nf-schema output to format I want.
                This gives a shape of:
                [
                    [
                        ChIP metadata map,
                        [ ChIP reads1 fastq file ],
                        [ ChIP reads2 fastq file ]
                    ],
                    [
                        Control metadata map,
                        [ Control reads1 fastq file ],
                        [ Control reads2 fastq file ]
                    ]
                ]
                This general shape is passed into pretty much everything downstream that takes reads in fastq format once it's broken into each individual sample channel.
            */
            .map { meta, chipReads1, chipReads2, controlReads1, controlReads2 ->
                createSampleReadsChannel(meta, chipReads1, chipReads2, controlReads1, controlReads2)
            }
            // pull the chip and control channels apart
            .multiMap { chipList, controlList ->
                chip:    chipList
                control: controlList
            }
            .set { ch_multi_samples }

        /*
            mix the chip and control samples back together to a flat channel of shape:
            [
                metadata map,
                [ reads1 fastq file ],
                [ reads2 fastq file ]
            ]
            This is shape we want as mentioned above
        */
        ch_multi_samples.chip
            .concat(ch_multi_samples.control)
            .set { ch_samples }
        ch_samples.dump(tag: "ch_samples", pretty: true)

    emit:
        samples = ch_samples
}


/**
 * Create a list of metadata and reads from the output of nf-schema `samplesheetToList`.
 *
 * Adds additional metadata to the metadata and wrangles reads to be fed into the rest of the pipeline.
 *
 * @param meta A LinkedHashMap of metadata constructed by nf-schema `samplesheetToList`.
 * @param r1 A String path to reads 1 fastq file.
 * @param r2 An optional String path to reads 2 fastq file.
 *
 * @return List of shape [ metadata, chipReads1, chipReads2, controlR1, controlR2 ] where reads2 is an empty file if no R2 file was supplied.
 */
def createSampleReadsChannel(meta, chipR1, chipR2, controlR1, controlR2) {
    // store metadata common between for both ChIP and Control libraries in a Map shallow copied from the input meta map
    def commonMetadata = meta.clone()
    // convert replicate to String
    commonMetadata.replicate = commonMetadata.replicate.toString()
    // add the fact that these are raw reads to the metadata
    commonMetadata.trimStatus = "raw"
    // add lane information to common metadata
    if(commonMetadata.lane) {
        // update lane number to properly formatted string, i.e. exactly three digits padded with 0s if necessary
        commonMetadata.lane = MetadataUtils.padLaneWithZeros(commonMetadata.lane)
    } else {
        // if no lane number, remove the lane key
        commonMetadata.remove('lane')
    }

    /*
        Format reads and metadata for ChIP libraries
    */ 
    // create file objects from ChIP R1 and R2
    def (chipR1File, chipR2File) = wrangleReadPairs(chipR1, chipR2)

    // fill in ChIP specific metadata
    def chipMetadata = commonMetadata.clone()
    chipMetadata.mode = 'chip'
    chipMetadata.readType = chipR2.isEmpty() ? "single" : "paired"

    // get read group information for ChIP
    chipMetadata.rgFields = getRGFields(chipR1File, chipMetadata)

    /*
        Format reads and metadata for Control libraries
    */ 
    // create file objects from ChIP R1 and R2
    def (controlR1File, controlR2File) = wrangleReadPairs(controlR1, controlR2)

    // fill in ChIP specific metadata
    def controlMetadata = commonMetadata.clone()
    controlMetadata.mode = 'control'
    controlMetadata.readType = controlR2.isEmpty() ? "single" : "paired"

    // build read group line for ChIP
    // get sequence ID line from fastq.gz
    controlMetadata.rgFields = getRGFields(controlR1File, controlMetadata)

    return [
        [ chipMetadata, chipR1File, chipR2File ],
        [ controlMetadata, controlR1File, controlR2File ]
    ]
}


/**
 * Create a list of R1 and R2 reads file objects.
 *
 * Creates file objects from R1 and R2 reads file paths.
 * If the read type is single end, then a file object is construct from the R1 reads path and an empty file object with a compatible name is created for the R2 reads to act as a placeholder.
 *
 * @param r1 A string path R1 fastq file.
 * @param r2 An optional String path to R2 fastq file.
 *
 * @return List of shape [ R1 file object, R2 file object ] where R2 file object is empty if no R2 file was supplied. 
 */
def wrangleReadPairs(r1, r2) {
    // construct file object for R1 reads
    def reads1 = file(r1)

    // construct file object for R2 reads
    // if R2 reads is empty, i.e. single end reads, make an empty file to act as a placeholder for all processes that expect some R2 file object
    // otherwise just construct the file object for R2 reads
    if(r2.isEmpty()) {
        def emptyFileName = "${r1.simpleName}.NOFILE"
        def emptyFilePath = file("${workDir}").resolve(emptyFileName)
        file("${projectDir}/assets/NO_FILE").copyTo(emptyFilePath)
        reads2 = file(emptyFilePath)
    } else {
        reads2 = file(r2)
    }

    return [ reads1, reads2 ]
}


/**
 * Get RG fields from a reads file or a metadata object
 *
 * @params readsFile a reads file object to a fastq file.
 * @params metadata a metadata map
 *
 * @return map of read group fields
 */
def getRGFields(readsFile, metadata) {
    // get sequence ID line from fastq.gz
    def sequenceIdentifier = ReadGroup.readFastqFirstSequenceIdentifier(readsFile)
    def sequenceIdentifierMatcher = ReadGroup.matchSequenceIdentifier(sequenceIdentifier)

    // return a map of RG fields
    return ReadGroup.buildRGFields(metadata, sequenceIdentifierMatcher)
}
