include { khmer_unique_kmers } from '../modules/khmer/unique_kmers'
include { macs3_callpeak     } from '../modules/macs3/callpeak'
include { samtools_view      } from '../modules/samtools/view'


workflow CALL_PEAKS {
    take:
        alignments
        genome

    main:
        // compute effective genome size
        khmer_unique_kmers(genome)

        // filter mappings
        samtools_view(alignments)
        ch_mappings = samtools_view.out.bamFilteredIndexed

        // Pair ChIP and control samples for each sampleName - target - controlType - replica pair
        ch_mappings
            // separate into chip and control channels
            .branch { metadata, bam, bai ->
                chip: metadata.mode == "chip"
                    def meta = metadata.clone()
                    meta.remove('mode')
                    return [ buildPairChIPControlGroupKey(metadata), meta, bam, bai ]

                control: metadata.mode == "control"
                    def meta = metadata.clone()
                    meta.remove('mode')
                    return [ buildPairChIPControlGroupKey(metadata), meta, bam, bai ]
            }
            .set { ch_separate_alignments }

        ch_separate_alignments.chip
            // pair chip and control datasets
            .join(
                ch_separate_alignments.control
            )
            // get rid of grouping key and combine metadata
            .map { mappingsGroupKey, chipMeta, chipBam, chipBai, controlMeta, controlBam, controlBai ->
                return [
                    // combine metadata
                    MetadataUtils.intersectListOfMetadata([chipMeta, controlMeta]),
                    chipBam,
                    chipBai,
                    controlBam,
                    controlBai
                ]
            }
            .set { ch_paired_chip_control_alignments }

        macs3_callpeak(
            ch_paired_chip_control_alignments,
            khmer_unique_kmers.out.uniqueKmers
        )
        ch_callPeaksLog = macs3_callpeak.out.callpeakLog

    emit:
        callPeaksLog = ch_callPeaksLog
}


String buildPairChIPControlGroupKey(metadata) {
    // the grouping key beings with the sample name
    ArrayList pairGroupKeyComponents = [metadata.sampleName]

    // if the sample metadata contains all the chip information, add it
    // don't add mode since this would prevent chip and control samples from having a common key
    if (metadata.target) pairGroupKeyComponents += metadata.target
    if (metadata.controlType) pairGroupKeyComponents += "${metadata.controlType}-control"
    if (metadata.replicate) pairGroupKeyComponents += "rep${metadata.replicate}"

    return pairGroupKeyComponents.join('_')
}
