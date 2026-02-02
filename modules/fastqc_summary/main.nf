process fastqc_summary {
    tag "${MetadataUtils.buildStemName(metadata)}"

    label 'fastqc_summary'

    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    publishDir(
        path:    "${params.publishDirReports}/.fastqc",
        mode:    "${params.publishMode}",
        pattern: '*_fastqc-summary.json'
    )

    input:
        tuple val(metadata), path(reads1FastqcZip), path(reads2FastqcZip)

    output:
        tuple val(metadata), path('*_R1_fastqc-summary.json'), path('*_R2_fastqc-summary.{json,NOFILE}'), emit: fastqcSummary

    script:
        def reads1FastqcZipSummaryName = "${MetadataUtils.buildStemName(metadata)}_${metadata.trimStatus}_R1_fastqc-summary.json"

        if ( metadata.readType == 'single' ) {
            def reads2FastqcZipSummaryName = "${MetadataUtils.buildStemName(metadata)}_${metadata.trimStatus}_R2_fastqc-summary.NOFILE"

            """
            fastqc-summary \\
                --output ${reads1FastqcZipSummaryName} \\
                ${reads1FastqcZip}

            touch ${reads2FastqcZipSummaryName}
            """
        } else if ( metadata.readType == 'paired' ) {
            def reads2FastqcZipSummaryName = "${MetadataUtils.buildStemName(metadata)}_${metadata.trimStatus}_R2_fastqc-summary.json"

            """
            fastqc-summary \\
                --output ${reads1FastqcZipSummaryName} \\
                ${reads1FastqcZip}

            fastqc-summary \\
                --output ${reads2FastqcZipSummaryName} \\
                ${reads2FastqcZip}
            """
        }
}
