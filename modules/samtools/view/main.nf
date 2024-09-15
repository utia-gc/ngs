process samtools_view {
    tag "${stemName}"

    // Process settings label
    label 'samtools'

    // Resource labels
    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    // Publish data
    publishDir(
        path:    "${params.publishDirData}/alignments/filtered",
        mode:    "${params.publishMode}",
        pattern: "${stemName}_filtered.bam{,.bai}"
    )

    input:
        tuple val(metadata), path(bam), path(bai)

    output:
        tuple val(metadata), path('*.bam'), path('*.bam.bai'), emit: bamFilteredIndexed

    script:
        String args = new Args(task.ext).buildArgsString()

        stemName = MetadataUtils.buildStemName(metadata)

        """
        samtools view \\
            --bam \\
            --with-header \\
            --output ${stemName}_filtered.bam \\
            ${args} \\
            "${bam}"

        samtools index ${stemName}_filtered.bam
        """
}
