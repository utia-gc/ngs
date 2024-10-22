include { multiqc as multiqc_alignments } from "../modules/multiqc.nf"
include { samtools_idxstats             } from '../modules/samtools_idxstats.nf'
include { samtools_flagstat             } from '../modules/samtools_flagstat.nf'
include { samtools_stats                } from '../modules/samtools_stats.nf'


workflow QC_Alignments {
    take:
        alignmentsIndividual
        alignmentsMerged
        // map_log

    main:
        samtools_idxstats(alignmentsIndividual)
        samtools_flagstat(alignmentsIndividual)

        samtools_stats(alignmentsMerged)

        ch_multiqc_alignments = Channel.empty()
            .concat(samtools_idxstats.out.idxstat)
            .concat(samtools_flagstat.out.flagstat)
            .concat(samtools_stats.out.samtools_stats)
            .concat(samtools_stats.out.samtools_IS)
            .concat(samtools_stats.out.samtools_COV)
            // .concat(map_log)
            .collect(
                sort: { a, b ->
                    a.name <=> b.name
                }
            )

        multiqc_alignments(
            ch_multiqc_alignments,
            file("${projectDir}/assets/multiqc_config.yaml"),
            'alignments'
        )

    emit:
        multiqc = ch_multiqc_alignments
}
