process gunzip {
    tag "${archive}"

    label 'base'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    input:
        path archive
    
    output:
        path "${archive.toString() - '.gz'}", emit: gunzip
    
    script:
        """
        gunzip \
            --force \
            ${archive}
        """
}
