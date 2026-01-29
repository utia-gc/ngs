workflow Group_Reads {
    take:
        reads

    main:
        ch_reads_grouped = reads
            .map { metadata, reads1, reads2 ->
                [ metadata.sampleName, metadata, reads1, reads2 ]
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

    emit:
        reads_grouped = ch_reads_grouped
}
