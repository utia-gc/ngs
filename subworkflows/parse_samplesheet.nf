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
                    metadata map,
                    [ reads1 fastq file ],
                    [ reads2 fastq file ]
                ]
                This general shape is passed into pretty much everything downstream that takes reads in fastq format.
            */
            .map { meta, reads1, reads2 ->
                createSampleReadsChannel(meta, reads1, reads2)
            }
            .set { ch_samples }

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
 * @return List of shape [ metadata, [ reads1 ], [ reads2 ] ] where reads2 is an empty file if no R2 file was supplied.
 */
def createSampleReadsChannel(meta, r1, r2) {
    // store metadata in a Map shallow copied from the input meta map
    metadata = meta.clone()
    // fill in required metadata
    metadata.trimStatus = "raw"
    metadata.readType   = r2.isEmpty() ? "single" : "paired"
    if(metadata.lane) {
        // update lane number to properly formatted string, i.e. exactly three digits padded with 0s if necessary
        metadata.lane = MetadataUtils.padLaneWithZeros(metadata.lane)
    } else {
        // if no lane number, remove the lane key
        metadata.remove('lane')
    }

    // store reads in lists
    def reads1 = file(r1)
    if(r2.isEmpty()) {
        def emptyFileName = "${reads1.simpleName}.NOFILE"
        def emptyFilePath = file("${workDir}").resolve(emptyFileName)
        file("${projectDir}/assets/NO_FILE").copyTo(emptyFilePath)
        reads2 = file(emptyFilePath)
    } else {
        reads2 = file(r2)
    }

    // build read group line
    // get sequence ID line from fastq.gz
    def sequenceIdentifier = ReadGroup.readFastqFirstSequenceIdentifier(reads1)
    def sequenceIdentifierMatcher = ReadGroup.matchSequenceIdentifier(sequenceIdentifier)
    metadata.rgFields = ReadGroup.buildRGFields(metadata, sequenceIdentifierMatcher)

    return [ metadata, reads1, reads2 ]
}
