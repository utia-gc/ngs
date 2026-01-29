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
        ch_parsedSamplesheetRows = Channel
            // use nf-schema to handle samplesheet parsing
            // and create a channel of parsed samplesheet rows
            .fromList(
                samplesheetToList(samplesheet, "${projectDir}/assets/schema_samplesheet.json")
            )
            /* Filter samples into buckets of excluded or retained samples
            Excluded samples go into the first bucket with a condition they violate.
            Otherwise, they fall down into the retained bucket.
            */
            .branch { meta, reads1, reads2 ->
                // capture excluded samples
                // exclude sample if the reads1 file is empty
                reads1IsEmpty: isEmpty(file(reads1))
                // catch retained samples
                retained: true
            }

        /* Reshape nf-schema output for retained samples to desired shape.
        This gives a shape of:
            [
                metadata map,
                [ reads1 fastq file ],
                [ reads2 fastq file ]
            ]
        This general shape is passed into pretty much everything downstream that takes reads in fastq format.
        */
        ch_samples = ch_parsedSamplesheetRows.retained
            .map { meta, reads1, reads2 ->
                createSampleReadsChannel(meta, reads1, reads2)
            }

        // log warnings for excluded samples
        ch_parsedSamplesheetRows.reads1IsEmpty
            .map { meta, reads, reads2 ->
                log.warn("SAMPLE EXCLUSION: '${MetadataUtils.buildStemName(meta)}' excluded from analysis for empty reads1 file.")
            }

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


/**
 * Determine whether or not a file is empty
 *
 * This method is necessary because the Path.isEmpty() method returns false for gzip compressed files.
 *
 * @param fq A Path for a fastq file
 *
 * @return A boolean indicating whether or not the fastq file is empty.
*/
def isEmpty(Path fq) {
    // set decimal representation of first byte of empty file
    def emptyDecimal = -1
    def firstByteOfFastq = readFirstByte(fq)

    return firstByteOfFastq == emptyDecimal
}


/**
 * Read the first byte of a gzip compressed file.
 *
 * @param f A Path object for a gzip compressed file.
 *
 * @return An integer representation of the first byte of the file.
*/
def readFirstByte(Path f) {
    f.withInputStream { fis ->
        new java.util.zip.GZIPInputStream(fis).withStream { gis ->
            return gis.read()
        }
    }
}
