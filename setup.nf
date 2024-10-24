workflow {
    LinkedHashMap decodeMap = buildSampleNameDecodeMap(file(params.decode))

    fastqPairs = Channel
        .fromFilePairs(params.readsSources, checkIfExists: true, size: -1)
        .dump(tag: 'fastq file pairs', pretty: true)

    COPY_FASTQS(
        fastqPairs,
        file(params.readsDest),
        params.overwrite
    )

    WRITE_SAMPLESHEET(
        COPY_FASTQS.out.copiedFastqPairs,
        file(params.samplesheet),
        decodeMap
    )
}


workflow COPY_FASTQS {
    take:
        fastqPairs
        destinationDir
        overwrite

    main:
        // make the destination directory
        destinationDir.mkdirs()

        // iterate through all fastq file pairs
        fastqPairs.map { fastqPrefix, fastqs ->
            ArrayList fastqCopiedPaths = []

            // Either copy or skip copying each fastq file
            fastqs.each { fastq ->
                // Skip copying the fastq file if it already exists in the destination directory and overwriting is turned off.
                if (existsInDestination(fastq, destinationDir) && !overwrite) {
                    log.info "fastq file '${fastq}' already exists in '${destinationDir}' and `params.overwrite` = false. Did not copy."
                    // add the copied fastq name to the list
                    fastqCopiedPaths << destinationDir.resolve(fastq.name)
                    return
                } else {
                    // Copy the fastq file
                    def fastqDestPath = fastq.copyTo(destinationDir)
                    log.info "Copied fastq file '${fastq}' --> '${fastqDestPath}'"
                    // add the copied fastq name to the list
                    fastqCopiedPaths << fastqDestPath
                }
            }
            return [fastqPrefix, fastqCopiedPaths]
        }
        .tap { copiedFastqPairs }
        .dump(tag: "Copied fastqs", pretty: true)

    emit:
        copiedFastqPairs = copiedFastqPairs
}


workflow WRITE_SAMPLESHEET {
    take:
        copiedFastqPairs
        samplesheet
        decodeMap

    main:
        // cast ch_readPairs to a map and write to a file
        copiedFastqPairs
            .map { stemName, reads ->
                def stemNameInfo = captureFastqStemNameInfo(stemName)
                "${decodeMap.get(stemNameInfo.sampleName) ?: stemNameInfo.sampleName},${stemNameInfo.lane},${reads[0]},${reads[1] ?: ''}"
            }
            .collectFile(
                name: samplesheet.name,
                newLine: true,
                storeDir: samplesheet.parent,
                sort: true,
                seed: 'sampleName,lane,reads1,reads2'
            )
}

/**
 * Make translation table of read names to sample name.
 *
 * @param  decode The Path to build the decode map from. First column is the sample name as found in the fastq file. Second column is the desired sample name.
 * @return        LinkedHashMap with keys as fastq sample names, and values as sample names.
 */
def buildSampleNameDecodeMap(decode) {
    // make translation table of read names to sample name
    LinkedHashMap decodeMap = [:]
    decode.eachLine { line, number ->
        // skip first line since it's header
        if (number == 1) {
            return
        }

        def splitLine = line.split(',')
        if (splitLine[0] == params.project) {
            def readsName = splitLine[1]
            def sampleName = (splitLine.size() == 3) ? splitLine[2] : ''
            decodeMap.put(readsName, sampleName)
        }
    }

    return decodeMap
}


def captureFastqStemNameInfo(String stemName) {
    def capturePattern = /(.*)_S(\d+)_L(\d{3})/
    def fastqMatcher = (stemName =~ capturePattern)

    if (fastqMatcher.find()) {
        LinkedHashMap stemNameInfo = [:]
        stemNameInfo.put('sampleName', fastqMatcher.group(1))
        stemNameInfo.put('lane', fastqMatcher.group(3))

        return stemNameInfo
    } else {
        log.error "fastq file stem manes do not "
    }
}


/**
 * Does a source file already exist in a destination directory?
 *
 * @param sourceFile     The file to be checked for existence.
 * @param destinationDir The desination directory to check for the source file name.
 * @return               `true` if the source file exists in the destination directory.
 */
boolean existsInDestination(sourceFile, destinationDir) {
    return destinationDir.resolve(sourceFile.name).exists()
}
