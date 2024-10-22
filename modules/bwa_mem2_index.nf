/**
 * Process to run bwa-mem2 index.
 * 
 * Generate bwa-mem2 index from a reference genome.
 * @see https://github.com/bwa-mem2/bwa-mem2
 * 
 * @input genome the uncompressed reference genome sequence in fasta format.
 * @emit index the reference index built by bwa-mem2 index.
 */
process bwa_mem2_index {
    tag "${genome.name}"

    label 'bwa_mem2'

    label 'max_cpu'
    label 'max_mem'
    label 'big_time'

    input:
        path genome

    output:
        path "${genome.name}*", emit: index

    script:
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        """
        bwa-mem2 index \
            ${args} \
            ${genome}
        """
}
