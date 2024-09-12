include { multiqc as multiqc_peaks } from "../modules/multiqc.nf"


workflow QC_Peaks {
    take:
        peaksLog

    main:
        ch_multiqcPeaks = Channel.empty()
            .concat( peaksLog.map { metadata, peakLog -> peakLog } )
            .collect(
                // sort based on file name
                sort: { a, b ->
                    a.name <=> b.name
                }
            )

        multiqc_peaks(
            ch_multiqcPeaks,
            file("${projectDir}/assets/multiqc_config.yaml"),
            'peaks'
        )

    emit:
        multiqc = ch_multiqcPeaks
}
