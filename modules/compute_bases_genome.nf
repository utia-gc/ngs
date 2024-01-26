/**
 * Process to compute number of bases in a genome.
 *
 * Compute number bases in a genome from a fasta index (.fai) file.
 * 
 * @input fai the fasta index of the reference genome.
 * @emit bases number of bases in reference genome.
 */
process compute_bases_genome {
    label 'base'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    input:
        path fai

    output:
        stdout emit: bases

    script:
        """
        awk 'BEGIN { FS = "\t"; OFMT = "%.0f" } ; { sum += \$2 } ; END { print sum }' ${fai} \\
            | tr -d '\n'
        """
}
