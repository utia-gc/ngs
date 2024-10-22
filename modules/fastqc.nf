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
        path('*.html'), emit: html
        path('*.zip'),  emit: zip

    script:
        String reads1NewName = "${MetadataUtils.buildStemName(metadata)}_${metadata.trimStatus}_R1.fastq.gz"

        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        if(metadata.readType == 'single') {
            """
            mv ${reads1} ${reads1NewName}

            fastqc \
                --quiet \
                --threads ${task.cpus} \
                ${args} \
                ${reads1NewName}
            """
        } else if(metadata.readType == 'paired') {
            String reads2NewName = "${MetadataUtils.buildStemName(metadata)}_${metadata.trimStatus}_R2.fastq.gz"

            """
            mv ${reads1} ${reads1NewName}
            mv ${reads2} ${reads2NewName}

            fastqc \
                --quiet \
                --threads ${task.cpus} \
                ${args} \
                ${reads1NewName} \
                ${reads2NewName}
            """
        }
}
