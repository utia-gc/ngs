workflow {
    // make translation table of read names to sample name
    decode = file(params.decode)
    decodeTable = [:]
    decode.eachLine { line, number ->
        // skip first line since it's header
        if (number == 1) {
            return
        }

        def splitLine = line.split(',')
        if (splitLine[0] == params.project) {
            def readsName = splitLine[1]
            def sampleName = (splitLine.size() == 3) ? splitLine[2] : ''
            decodeTable.put(readsName, sampleName)
        }
    }

    readsSource = file(params.readsSource)
    readsDest   = file(params.readsDest)

    COPY_READS(
        readsSource,
        readsDest,
        decodeTable
    )

    samplesheet = file(params.samplesheet)

    WRITE_SAMPLESHEET(
        readsDest,
        samplesheet,
        decodeTable
    )
}

workflow COPY_READS {
    take:
        source_reads_dir
        destination_reads_dir
        decode_table

    main:
        // make the destination directory
        destination_reads_dir.mkdirs()

        // combine patterns to match
        def combinedPatterns = decode_table.keySet().toList().join('|')
        log.info "Patterns to search for matches: ${combinedPatterns}"

        // iterate through all fastq.gz files in source directory
        source_reads_dir.eachFileMatch(~/.*(${combinedPatterns}).*\.fastq\.gz/) { fastq ->
            // copy files to copy dir
            def fastqDestPath = fastq.copyTo(destination_reads_dir)
            log.info "Copied fastq file ${fastq} --> ${fastqDestPath}"
        }
}

workflow WRITE_SAMPLESHEET {
    take:
        reads_dir
        samplesheet
        decode_table

    main:
        // create channel of read pairs
        Channel
            .fromFilePairs("${reads_dir}/*_R{1,2}_001.fastq.gz", size: -1, checkIfExists: true)
            .set { ch_readPairs }
        ch_readPairs.dump(tag: "ch_readPairs")

        // cast ch_readPairs to a map and write to a file
        ch_readPairs
            .map { stemName, reads ->
                def stemNameInfo = captureFastqStemNameInfo(stemName)
                "${decode_table.get(stemNameInfo.sampleName) ?: stemNameInfo.sampleName},${stemNameInfo.sampleNumber},${stemNameInfo.lane},${reads[0]},${reads[1] ?: ''}"
            }
            .collectFile(
                name: samplesheet.name,
                newLine: true,
                storeDir: samplesheet.parent,
                sort: true,
                seed: 'sampleName,sampleNumber,lane,reads1,reads2'
            )
}

def captureFastqStemNameInfo(String stemName) {
    def capturePattern = /(.*)_S(\d+)_L(\d{3})/
    def fastqMatcher = (stemName =~ capturePattern)

    if (fastqMatcher.find()) {
        stemNameInfo = [:]
        stemNameInfo.put('sampleName', fastqMatcher.group(1))
        stemNameInfo.put('sampleNumber', fastqMatcher.group(2))
        stemNameInfo.put('lane', fastqMatcher.group(3))

        return stemNameInfo
    } else {
        log.error "fastq file stem manes do not "
    }
}
