/**
 * Validate required params
 *
 * Check that required params exist. Throw exit status 64 if they don't.
 *
 * @param params The params for the Nextflow pipeline.
 * @param log The Nextflow log object.
 *
 * @return null
 */
static void validateRequiredParams(params, log) {
    validateMapTool(params, log)
}


/**
 * Validate map tool.
 *
 * Check that map tool param exists and is a valid map tool.
 * Throw exit status 64 if otherwise.
 *
 * @param params The params for the Nextflow pipeline.
 * @param log The Nextflow log object.
 *
 * @return null
 */
static void validateMapTool(params, log) {
    if (params.tools.map) {
        if (Tools.Map.isMapTool(params.tools.map)) {
            log.info "Using map tool '${params.tools.map}'"
        } else {
            log.error "'${params.tools.map}' is not a valid map tool."
            System.exit(64)
        }
    } else {
        log.error "Parameter 'tools.map' is required but was not provided."
        System.exit(64)
    }
}
