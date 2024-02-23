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

    readsSources = validateReadsSources(params.readsSources)
    readsDest    = file(params.readsDest)

    COPY_READS(
        readsSources,
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
        source_reads_dirs
        destination_reads_dir
        decode_table

    main:
        // make the destination directory
        destination_reads_dir.mkdirs()

        // combine patterns to match
        def combinedPatterns = decode_table.keySet().toList().join('|')
        log.info "Patterns to search for matches: ${combinedPatterns}"

        // iterate through all fastq.gz files in source directories
        source_reads_dirs.each { sourceReadsDir ->
            sourceReadsDir.eachFileMatch(~/.*(${combinedPatterns}).*\.fastq\.gz/) { fastq ->
                // copy files to copy dir
                def fastqDestPath = fastq.copyTo(destination_reads_dir)
                log.info "Copied fastq file ${fastq} --> ${fastqDestPath}"
            }
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
                "${decode_table.get(stemNameInfo.sampleName) ?: stemNameInfo.sampleName},${stemNameInfo.lane},${reads[0]},${reads[1] ?: ''}"
            }
            .collectFile(
                name: samplesheet.name,
                newLine: true,
                storeDir: samplesheet.parent,
                sort: true,
                seed: 'sampleName,lane,reads1,reads2'
            )
}

def captureFastqStemNameInfo(String stemName) {
    def capturePattern = /(.*)_S(\d+)_L(\d{3})/
    def fastqMatcher = (stemName =~ capturePattern)

    if (fastqMatcher.find()) {
        stemNameInfo = [:]
        stemNameInfo.put('sampleName', fastqMatcher.group(1))
        // stemNameInfo.put('sampleNumber', fastqMatcher.group(2))
        stemNameInfo.put('lane', fastqMatcher.group(3))

        return stemNameInfo
    } else {
        log.error "fastq file stem manes do not "
    }
}


/**
 * Validate reads source directories.
 *
 * @param  readsSources The params.readsSources argument
 * @return              A list of files to the paths specified in readsSources.
 */
def validateReadsSources(readsSources) {
    if (readsSources instanceof List) {
        // if readsSources is a list of strings, return a list containing file objects of those strings
        if (readsSources.every { it instanceof String }) {
            return readsSources.collect { file(it, checkIfExists: true) }
        }
        else {
            throw new IllegalArgumentException("params.readsSources is a list but contains non-string elements. Must be a list of valid paths or a single valid path.")
        }
    } else if (readsSources instanceof String) {
        // if readsSources is a string, return a list containing a file object of that string
        return [file(readsSources, checkIfExists: true)]
    } else {
        // if readsSources is neither a list of strings nor a string, throw an expection
        throw new IllegalArgumentException("params.readsSources must be a list of valid paths or a single valid path.")
    }
}
