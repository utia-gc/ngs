process macs3_callpeak {
    tag "${stemName}"

    // Process settings label
    label 'macs3'

    // Resources labels
    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    // Publish data
    publishDir(
        path:    "${params.publishDirData}/peaks/macs3",
        mode:    "${params.publishMode}",
        pattern: "${stemName}*"
    )

    input:
        tuple val(metadata), path(chipBam), path(chipBai), path(controlBam), path(controlBai)
        val   effectiveGenomeSize

    output:
        tuple val(metadata), path("${stemName}_peaks.xls"),        emit: callpeakLog
        tuple val(metadata), path("${stemName}_peaks.narrowPeak"), emit: narrowPeak
        tuple val(metadata), path("${stemName}_summits.bed"),      emit: summits

    script:
        String args = new Args(task.ext).buildArgsString()
        stemName = MetadataUtils.buildStemName(metadata)

        // set BAM format based on whether reads are paired-end or not
        String bamFormat = (metadata.readsType == 'single') ? 'BAM' : 'BAMPE'

        """
        macs3 callpeak \\
            --treatment ${chipBam} \\
            --control ${controlBam} \\
            --format ${bamFormat} \\
            --gsize ${effectiveGenomeSize} \\
            --name ${stemName} \\
            ${args}
        """
}
