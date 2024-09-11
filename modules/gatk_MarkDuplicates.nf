process gatk_MarkDuplicates {
    tag "${metadata.sampleName}"

    label 'gatk'

    label 'big_cpu'
    label 'big_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/alignments",
        mode:    "${params.publishMode}",
        pattern: "${stemName}.bam{,.bai}"
    )

    input:
        tuple val(metadata), path(bam)

    output:
        tuple val(metadata), path('*.bam'), path('*.bam.bai'), emit: bamMarkDupIndexed

    script:
        String args = new Args(task.ext).buildArgsString()

        stemName = MetadataUtils.buildStemName(metadata)

        """
        gatk MarkDuplicates \
            --INPUT ${bam} \
            --METRICS_FILE ${stemName}_MarkDuplicates-metrics.txt \
            --OUTPUT ${stemName}.bam \
            --CREATE_INDEX \
            ${args}

        mv ${stemName}.bai ${stemName}.bam.bai
        """
}
