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
        path "${fileName}.html", hidden: true,   emit: report
        path "${fileName}_data/*", hidden: true, emit: data

    script:
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        """
        multiqc \
            --filename ${fileName} \
            --config ${config} \
            ${args} \
            .
        """
}
