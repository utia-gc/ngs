/**
 * Process to run featureCounts from the Subread package.
 * 
 * Count reads within annotations with featureCounts
 *
 * @input alignments the name sorted aligned/mapped reads channel of format [metadata, BAM].
 * @input annotations the reference annotations in GTF format. Can be gzipped.
 *
 * @emit counts the output counts file channel of format [metadata, counts.txt].
 * @emit countsSummary the output summary file channel.
 */
process featureCounts {
    tag "${metadata.sampleName}"

    label 'subread'

    label 'huge_cpu'
    label 'med_mem'
    label 'huge_time'

    // publish counts file to data dir
    publishDir(
        path:    "${params.publishDirData}/counts",
        mode:    "${params.publishMode}",
        pattern: '*.txt'
    )
    // publish summary file to reports dir
    publishDir(
        path:    "${params.publishDirReports}/counts",
        mode:    "${params.publishMode}",
        pattern: '*.txt.summary'
    )

    input:
        tuple val(metadata), path(bam)
        path annotations

    output:
        tuple val(metadata), path('*.txt'), emit: counts
        path '*.txt.summary',               emit: countsSummary
    
    script:
        String args = new Args(task.ext).buildArgsString()

        """
        featureCounts \\
            -T ${task.cpus} \\
            -a ${annotations} \\
            -F GTF \\
            -o ${metadata.sampleName}.txt \\
            ${args} \\
            ${bam}
        """
}
