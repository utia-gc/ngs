process gatk_MergeSamFiles {
    tag "${metadata.sampleName}"

    label 'gatk'

    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    input:
        tuple val(metadata), path(bams), path(bais)

    output:
        tuple val(metadata), path('*_merged.bam'), emit: bamMerged

    script:
        // create the string of INPUT arguments
        // prepend '--INPUT' to each BAM
        // join into a space-delimted string
        def inputs = bams.collect { bam ->
            "--INPUT ${bam}" 
        }.join(' ')

        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        """
        gatk MergeSamFiles \
            ${inputs} \
            --OUTPUT ${metadata.sampleName}_merged.bam \
            ${args}
        """
}
