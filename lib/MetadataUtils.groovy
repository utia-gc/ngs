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

    // drop 'lane' key(s) from the interstected metadata map if they survived the intersection
    metadataIntersection.removeAll { k,v -> k == 'lane' }

    return metadataIntersection
}


/**
 * Pad the lane number with 0s to form a lane number that conforms to Illumina's fastq name standards.
 *
 * Illumina fastq files contain a lane number formatted as LXYZ where XYZ is always a string of three digits.
 * In most cases the lane number is 1, 2, 3, or 4, so the lane number in the file name is padded with 0s, e.g. L001, L002, etc.
 * This method convertions the lane number from an integer to a string that is padded with the appropriate amount of 0s.
 *
 * @param lane Integer lane number
 *
 * @return String lane number that is three characters long and padded by 0s if necessary.
 */
static String padLaneWithZeros(lane) {
  def numberZerosToAdd = 3 - lane.toString().length()
  
  return "0" * numberZerosToAdd + lane.toString()
}
