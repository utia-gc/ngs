process gatk_MarkDuplicates {
    tag "${metadata.sampleName}"

    label 'gatk'

    label 'med_mem'

    publishDir(
        path:    "${params.publishDirData}/alignments",
        mode:    "${params.publishMode}",
        pattern: "${metadata.sampleName}.bam{,.bai}"
    )

    input:
        tuple val(metadata), path(bam)

    output:
        tuple val(metadata), path('*.bam'), path('*.bam.bai'), emit: bamMarkDupIndexed

    script:
        String args = new Args(task.ext).buildArgsString()

        """
        gatk MarkDuplicates \
            --INPUT ${bam} \
            --METRICS_FILE ${metadata.sampleName}_MarkDuplicates-metrics.txt \
            --OUTPUT ${metadata.sampleName}.bam \
            --CREATE_INDEX \
            ${args}

        mv ${metadata.sampleName}.bai ${metadata.sampleName}.bam.bai
        """
}
