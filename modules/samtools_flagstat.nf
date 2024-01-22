process samtools_flagstat {
    tag "${metadata.sampleName}"

    label 'samtools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirReports}/.alignments",
        mode:    "${params.publishMode}",
        pattern: '*_samtools-flagstat.txt'
    )

    input:
        tuple val(metadata), path(bam), path(bai)

    output:
        path '*_samtools-flagstat.txt', emit: flagstat

    script:
        String stemName = MetadataUtils.buildStemName(metadata)

        """
        samtools flagstat \
            ${bam} \
            > ${stemName}_samtools-flagstat.txt
        """
}
