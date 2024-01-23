/**
 * Process to run qualimap rnaseq.
 * 
 * Report RNA-seq QC metrics and bias estimations with qualimap
 * @see http://qualimap.conesalab.org/doc_html/analysis.html#rna-seq-qc
 *
 * @input alignments the sorted and indexed aligned/mapped reads channel of format [metadata, BAM, BAM.BAI].
 * @input annotations the uncompressed reference annotations in GTF format.
 *
 * @emit qualimapRnaseq the output directory channel with qualimap rnaseq results.
 */
process qualimap_rnaseq {
    tag "${metadata.sampleName}"

    label 'qualimap'

    label 'med_cpu'
    label 'med_mem'
    label 'def_time'

    publishDir(
        path:    "${params.publishDirReports}/rnaseq/qualimap",
        mode:    "${params.publishMode}",
        pattern: '*'
    )

    input:
        tuple val(metadata), path(bam), path(bai)
        path annotations

    output:
        path '*', emit: qualimapRnaseq

    script:
        String args = new Args(task.ext).buildArgsString()

        """
        export JAVA_OPTS="-Djava.io.tmpdir=\${PWD}"

        qualimap rnaseq \\
            -bam ${bam} \\
            -gtf ${annotations} \\
            -outdir . \\
            -outformat HTML \\
            ${args}
        """
}
