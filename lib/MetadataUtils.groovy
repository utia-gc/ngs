/**
 * Build the stem name for a sample (e.g. reads or alignments) from a map of metadata.
 *
 * This is just a way to reuse code that dynamically adds sample number and lane info to sample names if they exist.
 *
 * @param metadata A LinkedHashMap of metadata for a sample.
 */
static String buildStemName(LinkedHashMap metadata) {
    // the stem name must start with the sample name
    ArrayList stemNameComponents = [metadata.sampleName]

    // add lane number to stem name if it exists
    if(metadata.lane) stemNameComponents += "L${metadata.lane}"

    return stemNameComponents.join('_')
}


/**
 * Find the intersection of a list of metadata maps.
 *
 * @params metadataList A list of metadata maps.
 *
 * @return LinkedHashMap A map of the consensus metadata, i.e. the intersection of all key:value pairs from the list of metadata maps.
 */
static LinkedHashMap intersectListOfMetadata(metadataList) {
    def metadataIntersection = metadataList[0]

    metadataList.each { metadata ->
        metadataIntersection = metadataIntersection.intersect(metadata)
    }

    /*
    // drop 'lane' key(s) from the interstected metadata map if they survived the intersection
    metadataIntersection.removeAll { k,v -> k == 'lane' }
    */

    return metadataIntersection
}
