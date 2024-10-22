/**
 * Process to run bwa-mem2 mem.
 * 
 * Align reads to reference genome using bwa-mem2.
 * @see https://github.com/bwa-mem2/bwa-mem2
 * 
 * @input reads the reads channel of format [metadata, [R1, R2]] where R2 is optional.
 * @input index the reference index built by bwa-mem2 index.
 * @emit alignments the aligned/mapped reads channel of format [metadata, alignments] where the alignments are in unsorted SAM format.
 */
process bwa_mem2_mem {
    tag "${metadata.sampleName}"

    label 'bwa_mem2'

    label 'sup_cpu'
    label 'sup_mem'
    label 'sup_time'

    input:
        tuple val(metadata), path(reads1), path(reads2)
        path  index

    output:
        tuple val(metadata), file('*.sam'), emit: alignments

    script:
        // get index prefix
        def indexPrefix = index[0].toString() - ~/\.0123/

        // set reads
        def reads = (metadata.readType == 'single') ? "${reads1}" : "${reads1} ${reads2}"

        // set stem name
        String stemName = MetadataUtils.buildStemName(metadata)

        // build read group line
        String rgLine = ReadGroup.buildRGLine(metadata.rgFields, 'bwamem2')

        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        """
        bwa-mem2 mem \
            ${args} \
            -R "${rgLine}" \
            -t ${task.cpus} \
            ${indexPrefix} \
            ${reads} \
            > ${stemName}.sam
        """
}
