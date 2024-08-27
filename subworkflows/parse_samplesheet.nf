workflow Parse_Samplesheet {
    take:
        samplesheet

    main:
        Channel
            .fromPath( samplesheet, checkIfExists: true )
            .splitCsv( header:true, sep:',' )
            .map { createSampleReadsChannel(it) }
            .set { ch_samples }

    emit:
        samples = ch_samples
}


// create a list of data from the csv
def createSampleReadsChannel(LinkedHashMap row) {
    // store metadata in a Map
    def metadata = [:]
    // fill in required metadata
    metadata.sampleName = row.sampleName
    metadata.trimStatus = "raw"
    metadata.readType   = row.reads2 ? "paired" : "single"
    // add optional metadata
    if (row.sampleNumber) {
        metadata.sampleNumber = row.sampleNumber
    }
    if (row.lane) {
        metadata.lane = row.lane
    }

    // store reads in lists
    def reads1 = file(row.reads1)
    if(metadata.readType == "single") {
        def emptyFileName = "${reads1.simpleName}.NOFILE"
        def emptyFilePath = file("${workDir}").resolve(emptyFileName)
        file("${projectDir}/assets/NO_FILE").copyTo(emptyFilePath)
        reads2 = file(emptyFilePath)
    } else if(metadata.readType == 'paired') {
        reads2 = file(row.reads2)
    }

    // build read group line
    // get sequence ID line from fastq.gz
    def sequenceIdentifier = ReadGroup.readFastqFirstSequenceIdentifier(reads1)
    def sequenceIdentifierMatcher = ReadGroup.matchSequenceIdentifier(sequenceIdentifier)
    metadata.rgFields = ReadGroup.buildRGFields(metadata, sequenceIdentifierMatcher)

    return [ metadata, reads1, reads2 ]
}
