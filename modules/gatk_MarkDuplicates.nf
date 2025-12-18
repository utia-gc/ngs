process gatk_MarkDuplicates {
    tag "${metadata.sampleName}"

    label 'gatk'

    label 'big_cpu'
    label 'big_mem'
    label 'med_time'

    input:
        tuple val(metadata), path(bam), path(bai)

    output:
        tuple val(metadata), path('*.bam'), path('*.bam.bai'), emit: bamMarkDupIndexed

    script:
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        """
        gatk MarkDuplicates \\
            --INPUT ${bam} \\
            --METRICS_FILE ${metadata.sampleName}_MarkDuplicates-metrics.txt \\
            --OUTPUT ${metadata.sampleName}.bam \\
            --CREATE_INDEX \\
            --TMP_DIR \${PWD} \\
            ${args}

        mv ${metadata.sampleName}.bai ${metadata.sampleName}.bam.bai
        """
}
