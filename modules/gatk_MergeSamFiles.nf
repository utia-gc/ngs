process gatk_MergeSamFiles {
    tag "${metadata.sampleName}"

    label 'gatk'

    label 'def_cpu'
    label 'med_mem'
    label 'def_time'

    input:
        tuple val(metadata), path(bams), path(bais)

    output:
        tuple val(metadata), path('*.bam'), path('*.bam.bai'), emit: bamMergedIndexed

    script:
        // create the string of INPUT arguments
        // prepend '--INPUT' to each BAM
        // join into a space-delimted string
        def inputs = bams.collect { bam ->
            "--INPUT ${bam}" 
        }.join(' ')

        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        """
        gatk MergeSamFiles \\
            ${inputs} \\
            --OUTPUT ${metadata.sampleName}_merged.bam \\
            --CREATE_INDEX \\
            --TMP_DIR \${PWD} \\
            ${args}

        mv ${metadata.sampleName}_merged.bai ${metadata.sampleName}_merged.bam.bai
        """
}
