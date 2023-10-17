include { Bwa_Mem2            } from '../subworkflows/bwa_mem2.nf'
include { Group_Alignments    } from '../subworkflows/group_alignments.nf'
include { samtools_sort_index } from '../modules/samtools_sort_index.nf'


/**
 * Workflow to map reads to a reference genome and compress, sort, and/or index the alignments.
 * 
 * @take
 */
workflow MAP_READS {
    take:
        reads
        genome
        map_tool

    main:
        switch( map_tool.toUpperCase() ) {
            case "BWA-MEM2":
                Bwa_Mem2(
                    reads,
                    genome
                )
                ch_alignments = Bwa_Mem2.out.alignments
                // ch_map_log    = Channel.empty()
                break
        }

        samtools_sort_index(ch_alignments)
          | Group_Alignments
          | view

    emit:
        alignments = samtools_sort_index.out.bamIndexed
        // map_log    = ch_map_log
}
