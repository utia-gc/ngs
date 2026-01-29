workflow Group_Alignments {
    take:
        bamIndexed

    main:
        ch_alignments_grouped = bamIndexed
            .map { metadata, bam, bai ->
                [ metadata.sampleName, metadata, bam, bai ]
            }
            .groupTuple()
            .map { sampleNameKey, metadata, bams, bais ->
                def metadataIntersection = MetadataUtils.intersectListOfMetadata(metadata)
                def bamsSorted = bams.sort { a, b ->
                    a.name.compareTo(b.name)
                }
                def baisSorted = bais.sort { a, b ->
                    a.name.compareTo(b.name)
                }

                [ metadataIntersection, bamsSorted, baisSorted ]
            }

    emit:
        alignments_grouped = ch_alignments_grouped
}
