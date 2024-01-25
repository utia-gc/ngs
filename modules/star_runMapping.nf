/**
 * Process to run STAR runMapping workflow.
 * 
 * Align reads to reference genome using STAR.
 * @see https://github.com/alexdobin/STAR
 * 
 * @input reads the reads channel of format [metadata, R1, R2].
 * @input index the reference index built by STAR genomeGenerate.
 * @emit alignments the aligned/mapped reads channel of format [metadata, alignments] where the alignments are in unsorted BAM format.
 */
process star_runMapping {
    tag "${metadata.sampleName}"
    
    label 'star'

    label 'huge_cpu'
    label 'huge_mem'
    label 'huge_time'

    input:
        tuple val(metadata), path(reads1), path(reads2)
        path index

    output:
        tuple val(metadata), file('*.sam'), emit: alignments
    
    script:
        // set reads
        String reads = (metadata.readType == 'single') ? "${reads1}" : "${reads1} ${reads2}"

        // set stem name
        String stemName = MetadataUtils.buildStemName(metadata)

        // build read group line
        String rgLine = ReadGroup.buildRGLine(metadata.rgFields, Tools.Map.STAR)

        String args = new Args(task.ext).buildArgsString()
        
        """
        STAR \
            --runThreadN ${task.cpus} \
            --genomeDir ${index} \
            --readFilesIn ${reads} \
            --readFilesCommand gunzip -c \
            --outFileNamePrefix ${stemName}_ \
            --outSAMattrRGline ${rgLine} \
            ${args}
        """
}
