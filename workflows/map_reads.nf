include { Bwa_Mem2            } from '../subworkflows/bwa_mem2.nf'
include { Group_Alignments    } from '../subworkflows/group_alignments.nf'
include { Star                } from '../subworkflows/star.nf'
include { gatk_MarkDuplicates } from '../modules/gatk_MarkDuplicates.nf'
include { gatk_MergeSamFiles  } from '../modules/gatk_MergeSamFiles.nf'
include { samtools_sort_index } from '../modules/samtools_sort_index.nf'
include { samtools_sort_name  } from '../modules/samtools_sort_name.nf'


/**
 * Workflow to map reads to a reference genome and compress, sort, and/or index the alignments.
 * 
 * @take
 */
workflow MAP_READS {
    take:
        reads
        genome
        annotationsGTF
        map_tool

    main:
        switch( map_tool.toUpperCase() ) {
            case 'BWAMEM2':
                Bwa_Mem2(
                    reads,
                    genome
                )
                ch_alignments = Bwa_Mem2.out.alignments
                break

            case 'STAR':
                Star(
                    reads,
                    genome,
                    annotationsGTF
                )
                ch_alignments = Star.out.alignments
        }

        samtools_sort_index(ch_alignments)
          | Group_Alignments
          | gatk_MergeSamFiles
          | gatk_MarkDuplicates
          | samtools_sort_name

    emit:
        alignmentsIndividualSortedByCoord = samtools_sort_index.out.bamSortedIndexed
        alignmentsMergedSortedByCoord     = gatk_MarkDuplicates.out.bamMarkDupIndexed
        alignmentsMergedSortedByName      = samtools_sort_name.out.bamSortedByName
}
