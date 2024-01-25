include { cutadapt } from "../modules/cutadapt.nf"
include { fastp    } from "../modules/fastp.nf"

/**
 * Workflow to process reads.
 * Reads should be trimmed here, if necessary.
 */
workflow Trim_Reads {
    take:
        reads_raw
        trim_tool

    main:
        switch( Tools.Trim.valueOf(trim_tool.toUpperCase()) ) {
            case Tools.Trim.CUTADAPT:
                cutadapt(
                    reads_raw,
                    params.r1_adapter,
                    params.r2_adapter,
                    params.minimum_length
                )
                ch_reads_trim = cutadapt.out.reads
                ch_trim_log   = cutadapt.out.log
                break

            case Tools.Trim.FASTP:
                fastp(reads_raw)
                ch_reads_trim = fastp.out.reads
                ch_trim_log   = fastp.out.log
                break
        }

        // update trim status in metadat
        ch_reads_trim
            .map { metadata, reads1, reads2 ->
                def meta = metadata.clone()
                meta.put('trimStatus', 'trimmed')
                [ meta, reads1, reads2 ]
            }
            .set { ch_reads_trim_updated }

    emit:
        reads_trim = ch_reads_trim_updated
        trim_log   = ch_trim_log
}
