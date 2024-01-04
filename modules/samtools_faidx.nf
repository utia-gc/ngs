process samtools_faidx {
    tag "${fasta}"

    label 'samtools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    input:
        path fasta

    output:
        path '*.fai', emit: fai

    script:
        """
        samtools faidx ${fasta}
        """
}
