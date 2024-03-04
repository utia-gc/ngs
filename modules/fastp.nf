process fastp {
    tag "${metadata.sampleName}"

    label 'fastp'

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirReports}/.reads/trim",
        mode:    "${params.publishMode}",
        pattern: '*_fastp.json'
    )

    input:
        tuple val(metadata), path(reads1), path(reads2)
        path adapterFasta

    output:
        tuple val(metadata), path("*_trimmed_R1.fastq.gz"), path("*_trimmed_R2{.fastq.gz,.NOFILE}"), emit: reads
        path("*_fastp.json"), emit: log

    script:
        String stemName = MetadataUtils.buildStemName(metadata)
        String reads1NewName = "${stemName}_${metadata.trimStatus}_R1.fastq.gz"

        String args = new Args(task.ext).buildArgsString()

        if(metadata.readType == 'single') {
            """
            mv ${reads1} ${reads1NewName}

            fastp \
                --thread ${task.cpus} \
                --in1 ${reads1NewName} \
                --out1 ${stemName}_trimmed_R1.fastq.gz \
                --json ${stemName}_fastp.json \
                --adapter_fasta ${adapterFasta} \\
                ${args}

            cp ${reads2} ${stemName}_trimmed_R2.NOFILE
            """
        } else if(metadata.readType == 'paired') {
            String reads2NewName = "${stemName}_${metadata.trimStatus}_R2.fastq.gz"

            """
            mv ${reads1} ${reads1NewName}
            mv ${reads2} ${reads2NewName}

            fastp \
                --thread ${task.cpus} \
                --in1 ${reads1NewName} \
                --in2 ${reads2NewName} \
                --out1 ${stemName}_trimmed_R1.fastq.gz \
                --out2 ${stemName}_trimmed_R2.fastq.gz \
                --json ${stemName}_fastp.json \
                --adapter_fasta ${adapterFasta} \\
                ${args}
            """
        }
}
