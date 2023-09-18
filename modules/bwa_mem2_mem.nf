/**
 * Process to run bwa-mem2 mem.
 * 
 * Align reads to reference genome using bwa-mem2.
 * @see https://github.com/bwa-mem2/bwa-mem2
 * 
 * @input reads the reads channel of format [metadata, [R1, R2]] where R2 is optional.
 * @input index the reference index built by bwa-mem2 index.
 * @emit alignments the aligned/mapped reads channel of format [metadata, alignments] where the alignments are in unsorted SAM format and metadata has additional fields to reflect this.
 */
process bwa_mem2_mem {
    tag "${metadata.sampleName}"

    label 'bwa_mem2'

    input:
        tuple val(metadata), path(reads)
        path  index

    output:
        tuple val(metadata), file('*.sam'), emit: alignments

    script:
        // update alignments metadata
        metadata.put('format', 'SAM')
        metadata.put('sorted', false)

        // get index prefix
        def indexPrefix = index[0].toString() - ~/\.0123/

        """
        bwa-mem2 mem \
            -t ${task.cpus} \
            ${indexPrefix} \
            ${reads} \
            > ${metadata.sampleName}.sam
        """
}