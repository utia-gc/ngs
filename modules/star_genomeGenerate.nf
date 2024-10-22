process star_genomeGenerate {
    tag "${genome.name}"

    label 'star'

    label 'sup_cpu'
    label 'sup_mem'
    label 'med_time'

    input:
        path genome
        path annotationsGTF

    output:
        path 'STAR', emit: index

    script:
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        """
        mkdir STAR

        STAR \
            --runMode genomeGenerate \
            --genomeFastaFiles ${genome} \
            --sjdbGTFfile ${annotationsGTF} \
            --genomeDir STAR \
            --runThreadN ${task.cpus} \
            ${args}
        """
}
