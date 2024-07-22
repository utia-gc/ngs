import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.zip.GZIPInputStream

/**
 * Build the read group line for the specified tool from a map of read group fields.
 *
 * Most tools (typically mapping tools but I'm not making any assumptions here) have the ability to add read group information that is specified as a command line argument.
 * Most of these tools expect the read group argument to be in slightly different formats.
 * The purpose of this method is to build the read group line of argument for a specific command line tool.
 *
 * @params LinkedHashMap rgFields A map of read group fields as tag:value pairs. First field must be ID.
 * @params String tool The tool to build a read group line for.
 *
 * @return String Read group line.
 */
public static String buildRGLine(rgFields, tool) {
    String rgLine = ''
    switch (tool.toUpperCase()) {
        case 'BWAMEM2':
            rgLine = buildBwaMem2RGLine(rgFields)
            break

        case 'STAR':
            rgLine = buildSTARRGLine(rgFields)
            break
    }

    return rgLine
}

/**
 * Build the read group line for bwa-mem2 from a map of read group fields.
 *
 * @params LinkedHashMap rgFields A map of read group fields as tag:value pairs. First field must be ID.
 *
 * @return String Read group line for bwa-mem2.
 */
private static String buildBwaMem2RGLine(rgFields) {
    ArrayList rgLineElements = ['@RG']

    rgFields.each { tag, value ->
        rgLineElements += "${tag}:${value}"
    }

    return rgLineElements.join('\t')
}

/**
 * Build the read group line for STAR from a map of read group fields.
 *
 * @params LinkedHashMap rgFields A map of read group fields as tag:value pairs. First field must be ID.
 *
 * @return String Read group line for STAR.
 */
private static String buildSTARRGLine(rgFields) {
    ArrayList rgLineElements = []

    rgFields.each { tag, value ->
        rgLineElements += "${tag}:${value}"
    }

    return rgLineElements.join(' ')
}

/**
 * Build the read group fields from sample metadata and matcher data from the sequence identifier.
 *
 * @params LinkedHashMap metadata A metadata map.
 * @params Matcher matcher A matcher object of sequence identifier.
 *
 * @return LinkedHashMap Read group fields containing at least ID, SM, LB, and PL fields.
 */
static LinkedHashMap buildRGFields(metadata, matcher) {
    def rgFields = [:]

    // add dynamically determined read group fields -- ID and PU
    if(matcher.find()) {
        rgFields += ['ID': "${matcher.group('instrument')}_${matcher.group('runNumber')}_${matcher.group('flowcellID')}.${matcher.group('lane')}"]
        rgFields += ['PU': "${matcher.group('flowcellID')}.${matcher.group('lane')}.${matcher.group('index')}"]
    } else {
        rgFields += ['ID': metadata.lane ? "${metadata.sampleName}.${metadata.lane}" : "${metadata.sampleName}"]
    }

    // add more straightforwardly determined dynamic fields
    rgFields += ['SM': "${metadata.sampleName}"]
    rgFields += ['LB': "${metadata.sampleName}"]

    // add static fields
    rgFields += ['PL': "ILLUMINA"]

    return rgFields
}

/**
 * Match sequence identifier against valid Illumina fastq file format
 *
 * @params String sequenceIdentifier The sequence identifier line. Should have the leading '@' stripped.
 *
 * @return Matcher A matcher for the sequenceIdentifier against a validated sequence identifer regex pattern.
 */
static def matchSequenceIdentifier(sequenceIdentifier) {
    def validSequenceIdentifierPattern = /^(?<instrument>[a-zA-Z0-9_]+):(?<runNumber>[0-9]+):(?<flowcellID>[a-zA-Z0-9]+):(?<lane>[0-9]+):(?<tile>[0-9]+):(?<xPos>[0-9:]+):(?<yPos>[0-9]+)(:(?<umi>[ATGCN+]+))? (?<read>[12]):(?<isFiltered>[YN]):(?<controlNumber>[0-9]+):(?<index>[ATGCN+]+)$/

    return (sequenceIdentifier =~ validSequenceIdentifierPattern)
}

/**
 * Read the first sequence identifier from a fastq.gz file
 *
 * @params fastqPath Path object to fastq file.
 *
 * @return String sequence identifier line.
 */
static String readFastqFirstSequenceIdentifier(fastqPath) {
    def sequenceIdentifier = ''
    def fastqInputStream = new GZIPInputStream(fastqPath.newInputStream())
    try {
        def reader = new BufferedReader(new InputStreamReader(fastqInputStream, 'UTF-8'))
        sequenceIdentifier = reader.readLine()[1..-1]
    } finally {
        fastqInputStream.close()
    }

    return sequenceIdentifier
}
