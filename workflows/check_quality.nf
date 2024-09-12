include { QC_Alignments           } from '../subworkflows/qc_alignments.nf'
include { QC_Peaks                } from '../subworkflows/qc_peaks.nf'
include { QC_Reads                } from '../subworkflows/qc_reads.nf'
include { multiqc as multiqc_full } from "../modules/multiqc.nf"


workflow CHECK_QUALITY {
    take:
        reads_raw
        reads_prealign
        trim_log
        genome_index
        alignmentsIndividual
        alignmentsMerged
        peaksLog

    main:
        QC_Reads(
            reads_raw,
            reads_prealign,
            trim_log,
            genome_index
        )
        ch_multiqc_reads = QC_Reads.out.multiqc

        QC_Alignments(
            alignmentsIndividual,
            alignmentsMerged
        )
        ch_multiqc_alignments = QC_Alignments.out.multiqc

        QC_Peaks(
            peaksLog
        )
        ch_multiqcPeaks = QC_Peaks.out.multiqc

        ch_multiqc_full = Channel.empty()
            .concat(ch_multiqc_reads)
            .concat(ch_multiqc_alignments)
            .concat(ch_multiqcPeaks)
            .collect(
                // sort based on file name
                sort: { a, b ->
                    a.name <=> b.name
                }
            )
        multiqc_full(
            ch_multiqc_full,
            file("${projectDir}/assets/multiqc_config.yaml"),
            params.projectTitle
        )
}
