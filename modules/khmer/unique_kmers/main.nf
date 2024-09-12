process khmer_unique_kmers {
    tag "${fasta}"

    // Process settings label
    label 'khmer'

    // Resources labels
    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    input:
        path fasta

    output:
        stdout emit: uniqueKmers

    script:
        String args = new Args(task.ext).buildArgsString()

        """
        # count unique kmers
        unique-kmers.py \\
            --report unique_kmers_report.txt \\
            ${args} \\
            ${fasta}

        # extract total number of k-mers
        # this is the effective genome size
        # pull out the line with the total number of unique k-mers, extract the number with awk, then trim leading/trailing whitespace with xargs
        grep 'number of unique k-mers:' unique_kmers_report.txt \\
            | awk -F': ' '{print \$NF}' \\
            | xargs \\
            | tr -d '\n'
        """
}
