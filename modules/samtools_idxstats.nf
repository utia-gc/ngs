process samtools_idxstats {
    tag "${metadata.sampleName}"

    label 'samtools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirReports}/.alignments",
        mode:    "${params.publishMode}",
        pattern: '*_idxstat.txt'
    )

    input:
        tuple val(metadata), path(bam), path(bai)

    output:
        path '*_idxstat.txt', emit: idxstat

    script:
        String stemName = MetadataUtils.buildStemName(metadata)

        """
        samtools idxstats \
            ${bam} \
            > ${stemName}_idxstat.txt
        """
}
