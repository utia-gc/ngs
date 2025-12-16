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

        // sort and index alignments
        samtools_sort_index(ch_alignments)
        ch_alignmentsIndividualSortedByCoord = samtools_sort_index.out.bamSortedIndexed

        // merge alignments by sample
        ch_alignmentsIndividualSortedByCoord 
            | Group_Alignments
            | gatk_MergeSamFiles
        ch_alignmentsMergedSortedByCoord = gatk_MergeSamFiles.out.bamMergedIndexed

        // mark duplicates
        gatk_MarkDuplicates(ch_alignmentsMergedSortedByCoord)
        ch_alignmentsMergedSortedByCoordDupMarked = gatk_MarkDuplicates.out.bamMarkDupIndexed

        // sort alignments by name
        samtools_sort_name(ch_alignmentsMergedSortedByCoordDupMarked)
        ch_alignmentsMergedSortedByName = samtools_sort_name.out.bamSortedByName

    emit:
        alignmentsIndividualSortedByCoord = ch_alignmentsIndividualSortedByCoord
        alignmentsMergedSortedByCoord     = ch_alignmentsMergedSortedByCoordDupMarked
        alignmentsMergedSortedByName      = ch_alignmentsMergedSortedByName
}
