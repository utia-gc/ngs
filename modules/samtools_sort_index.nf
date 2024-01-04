/**
 * Compress, sort, and/or index alignments (SAM or BAM) with samtools.
 *
 * @input tuple the aligned/mapped reads channel of format [metadata, alignments] where the alignments are in sorted or unsorted SAM or BAM format and metadata has fields to reflect this.
 * @output bamIndexed the sorted and indexed aligned/mapped reads channel of format [metadata, BAM, BAM.BAI] where the alignments are in sorted BAM format and metadata has fields to reflect this.
 */
process samtools_sort_index {
    tag "${metadata.sampleName}"

    shell '/bin/bash', '-uo', 'pipefail'

    label 'samtools'

    label 'def_cpu'
    label 'def_mem'
    label 'lil_time'

    input:
        tuple val(metadata), path(alignments)

    output:
        tuple val(metadata), path("*.bam"), path("*.bam.bai"), emit: bamSortedIndexed

    
    shell:
        stemName = MetadataUtils.buildStemName(metadata)

        '''
        # detect if alignments is in BAM or SAM format
        # this is based on whether the file is BGZIP compressed
        # detect if a file has thh BGZIP header based on the first 16 bytes of the file
        hexdump -n 16 -C !{alignments} \
            | head -n 1 \
            | grep -q '1f 8b 08 04'
        if [[ $? -eq 0 ]]; then
            is_bam="true"
        else
            is_bam="false"
        fi

        # detect if alignments is coordinated sorted
        # this is based on whether SO:coordinate is set in the SAM/BAM header
        samtools head !{alignments} \
            | grep -Eq '^@HD\s.*SO:coordinate.*'
        if [[ $? -eq 0 ]]; then
            is_sorted="true"
        else
            is_sorted="false"
        fi

        # sort and index the alignment file if it's unsorted
        # this will write a sorted BAM regardless if the input is in SAM or BAM format
        if [[ $is_sorted == "false" ]]; then 
            samtools sort \
                -@ !{task.cpus} \
                -O bam \
                -o !{stemName}.bam \
                !{alignments}

            samtools index \
                -@ !{task.cpus} \
                !{stemName}.bam
        elif [[ $is_bam == "true" && $is_sorted == "true" ]]; then
            # produce file with stereotypical name for output
            mv -f !{alignments} !{stemName}.bam

            samtools index \
                -@ !{task.cpus} \
                !{stemName}.bam
        fi
        '''
}
