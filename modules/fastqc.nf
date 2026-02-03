process fastqc {
    tag "${metadata.sampleName}"

    label 'fastqc'

    label 'med_cpu'
    label 'def_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirReports}/.fastqc",
        mode:    "${params.publishMode}",
        pattern: '*{.html,.zip}'
    )

    input:
        tuple val(metadata), path(reads1), path(reads2)

    output:
        tuple val(metadata), path('*_R1_fastqc.html'), path('*_R2_fastqc{.html,.html.NOFILE}'), emit: html
        tuple val(metadata), path('*_R1_fastqc.zip'), path('*_R2_fastqc{.zip,.zip.NOFILE}'), emit: zip

    script:
        String reads1NewName = "${MetadataUtils.buildStemName(metadata)}_${metadata.trimStatus}_R1.fastq.gz"
        String reads2NewName = "${MetadataUtils.buildStemName(metadata)}_${metadata.trimStatus}_R2.fastq.gz"

        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        if(metadata.readType == 'single') {
            """
            mv ${reads1} ${reads1NewName}

            fastqc \\
                --quiet \\
                --threads ${task.cpus} \\
                --dir \${PWD} \\
                ${args} \\
                ${reads1NewName}

            # create empty versions of R2 ZIP and HTML files
            touch ${reads2NewName.replaceFirst(/\.fastq\.gz/, '_fastqc.html.NOFILE')}
            touch ${reads2NewName.replaceFirst(/\.fastq\.gz/, '_fastqc.zip.NOFILE')}
            """
        } else if(metadata.readType == 'paired') {
            """
            mv ${reads1} ${reads1NewName}
            mv ${reads2} ${reads2NewName}

            fastqc \\
                --quiet \\
                --threads ${task.cpus} \\
                --dir \${PWD} \\
                ${args} \\
                ${reads1NewName} \\
                ${reads2NewName}
            """
        }
}
