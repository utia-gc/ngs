process samtools_stats {
    tag "${metadata.sampleName}"

    label 'samtools'

    label 'def_cpu'
    label 'lil_mem'
    label 'def_time'

    publishDir(
        path:    "${params.publishDirReports}/.alignments",
        mode:    "${params.publishMode}",
        pattern: '*_samtools-stats.txt'
    )

    input:
        tuple val(metadata), path(bam), path(bai)

    output:
        path '*_samtools-stats.txt', emit: samtools_stats
        path '*_samtools-IS.txt',    emit: samtools_IS
        path '*_samtools-COV.txt',   emit: samtools_COV

    script:
        String stemName = MetadataUtils.buildStemName(metadata)

        """
        samtools stats \
            ${bam} \
            > ${stemName}_samtools-stats.txt

        # extract insert sizes
        grep ^IS ${stemName}_samtools-stats.txt \
            | cut -f 2,3 \
            > ${stemName}_samtools-IS.txt

        # extract coverages
        grep ^COV ${stemName}_samtools-stats.txt \
            | cut -f 3,4 \
            > ${stemName}_samtools-COV.txt
        """
}
