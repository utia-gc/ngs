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

    label 'big_cpu'
    label 'sup_mem'
    label 'sup_time'

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

        // fix RG line
        String rgLine = metadata.rgLine.replaceFirst(/^@RG\t/, '')
        
        """
        STAR \
            --runThreadN ${task.cpus} \
            --genomeDir ${index} \
            --readFilesIn ${reads} \
            --readFilesCommand gunzip -c \
            --outFileNamePrefix ${stemName}_ \
            --outSAMattrRGline ${rgLine}
        """
}