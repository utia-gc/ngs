process multiqc {
    tag "${fileName}"
    
    label 'multiqc'

    label 'def_cpu'
    label 'def_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirReports}/multiqc/${fileName}",
        mode:    "${params.publishMode}"
    )

    input:
        path('*')
        path config
        val fileName

    output:
        path("*html"),              emit: report
        path("${fileName}_data/*"), emit: data

    script:
        String args = new Args(task.ext).buildArgsString()

        """
        multiqc \
            --filename ${fileName} \
            --config ${config} \
            ${args} \
            .
        """
}
