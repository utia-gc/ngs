include { Trim_Reads } from "../subworkflows/trim_reads.nf"

/**
 * Workflow to process reads.
 * Reads should be trimmed and concatenated here, if necessary.
 */

workflow PROCESS_READS {
    take:
        reads_raw
        adapter_fasta

    main:
        if(!params.skipTrimReads) {
            Trim_Reads(
                reads_raw,
                params.trimTool,
                adapter_fasta
            )
            ch_reads_post_trim = Trim_Reads.out.reads_trim
            ch_trim_log        = Trim_Reads.out.trim_log
        } else {
            ch_reads_post_trim = reads_raw
            ch_trim_log        = Channel.empty()
        }

    emit:
        reads_pre_align = ch_reads_post_trim
        trim_log        = ch_trim_log
}
