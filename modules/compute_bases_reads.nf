/**
 * Process to compute number of bases in a genome.
 *
 * Compute number bases in a genome from a fasta index (.fai) file.
 * 
 * @input fai the fasta index of the reference genome.
 * @emit bases number of bases in reference genome.
 */
process compute_bases_reads {
    tag "${MetadataUtils.buildStemName(metadata)}"

    label 'base'

    label 'med_cpu'
    label 'def_mem'
    label 'def_time'

    input:
        tuple val(metadata), path(reads1), path(reads2)

    output:
        tuple val(metadata), stdout, emit: bases

    script:
        String reads = (metadata.readType == 'single') ? "${reads1}" : "${reads1} ${reads2}"

        """
        zcat ${reads} \\
            | grep -E '^[ACGTN]+\$' \\
            | tr -d '\n' \\
            | wc -m \\
            | tr -d '\n'
        """
}
