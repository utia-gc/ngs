workflow Group_Alignments {
    take:
        bamIndexed

    main:
        bamIndexed
            .map { metadata, bam, bai ->
                [ buildMappingsGroupKey(metadata), metadata, bam, bai ]
            }
            .groupTuple()
            .map { mappingsGroupKey, metadata, bams, bais ->
                def metadataIntersection = MetadataUtils.intersectListOfMetadata(metadata)
                def bamsSorted = bams.sort { a, b ->
                    a.name.compareTo(b.name)
                }
                def baisSorted = bais.sort { a, b ->
                    a.name.compareTo(b.name)
                }

                [ metadataIntersection, bamsSorted, baisSorted ]
            }
            .set { ch_alignments_grouped }

    emit:
        alignments_grouped = ch_alignments_grouped
}


String buildMappingsGroupKey(metadata) {
    // the grouping key beings with the sample name
    ArrayList mappingsGroupKeyComponents = [metadata.sampleName]

    // if the sample metadata contains all the chip information, add it
    if (metadata.mode == 'control') mappingsGroupKeyComponents += metadata.controlType
    if (metadata.mode == 'chip') mappingsGroupKeyComponents += metadata.mode
    if (metadata.target) mappingsGroupKeyComponents += metadata.target
    if (metadata.replicate) mappingsGroupKeyComponents += "rep${metadata.replicate}"

    return mappingsGroupKeyComponents.join('_')
}
