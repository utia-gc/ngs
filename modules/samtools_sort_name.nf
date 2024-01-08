/**
 * Sort BAM file by name.
 *
 * @input tuple the aligned/mapped reads channel of format [metadata, BAM, BAM.BAI].
 * @emit bamSortedByName the BAM sorted by name of format [metadata, BAM].
 */
process samtools_sort_name {
    tag "${stemName}"

    label 'samtools'

    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    input:
        tuple val(metadata), path(bam), path(bai)

    output:
        tuple val(metadata), path("output/*.bam"), emit:bamSortedByName

    
    shell:
        stemName = MetadataUtils.buildStemName(metadata)

        """
        # make a directory for output to avoid name clashes
        mkdir -p output

        samtools sort \\
            -n \\
            -@ ${task.cpus} \\
            -O bam \\
            -o output/${stemName}.bam \\
            ${bam}
        """
}
