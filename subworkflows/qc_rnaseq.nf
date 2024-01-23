include { multiqc as multiqc_rnaseq } from "../modules/multiqc.nf"
include { qualimap_rnaseq } from "../modules/qualimap_rnaseq.nf"               


/**
 * Workflow to run perform QC specific to RNA-seq specific.
 *
 * @take alignments the sorted and indexed aligned/mapped reads channel of format [metadata, BAM, BAM.BAI].
 * @take annotations the uncompressed reference annotations in GTF format.
 *
 * @emit multiqc channel of the files that go into the RNA-seq specific MultiQC
 */
workflow QC_Rnaseq {
    take:
        alignments
        annotations
        quantify_log

    main:
        qualimap_rnaseq(
            alignments,
            annotations
        )

        ch_multiqc_rnaseq = Channel.empty()
            .concat(qualimap_rnaseq.out.qualimapRnaseq)
            .concat(quantify_log)
            .collect( sort: true )

        multiqc_rnaseq(
            ch_multiqc_rnaseq,
            file("${projectDir}/assets/multiqc_config.yaml"),
            'rnaseq'
        )

    emit:
        multiqc = ch_multiqc_rnaseq
}
