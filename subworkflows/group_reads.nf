workflow Group_Reads {
    take:
        reads

    main:
        reads
            .map { metadata, reads1, reads2 ->
                [ buildReadsGroupKey(metadata), metadata, reads1, reads2 ]
            }
            .groupTuple()
            .map { sampleNameKey, metadata, reads1, reads2 ->
                def metadataIntersection = MetadataUtils.intersectListOfMetadata(metadata)
                def reads1Sorted = reads1.sort { a, b ->
                    a.name.compareTo(b.name)
                }
                def reads2Sorted = reads2.sort { a, b ->
                    a.name.compareTo(b.name)
                }

                [ metadataIntersection, reads1Sorted, reads2Sorted ]
            }
            .set { ch_reads_grouped }

    emit:
        reads_grouped = ch_reads_grouped
}


String buildReadsGroupKey(metadata) {
    // the grouping key beings with the sample name
    ArrayList readsGroupKeyComponents = [metadata.sampleName]

    // if the sample metadata contains all the chip information, add it
    if (metadata.mode == 'control') readsGroupKeyComponents += metadata.controlType
    if (metadata.mode == 'chip') readsGroupKeyComponents += metadata.mode
    if (metadata.target) readsGroupKeyComponents += metadata.target
    if (metadata.replicate) readsGroupKeyComponents += "rep${metadata.replicate}"

    return readsGroupKeyComponents.join('_')
}

