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
    validateSamplesheet(params, log)
    validateTrimTool(params, log)
    validateMapTool(params, log)
}


/**
 * Validate samplehseet
 *
 * Check that samplesheet param exists. Throw exit status 64 if it doesn't.
 *
 * @param params The params for the Nextflow pipeline.
 * @param log The Nextflow log object.
 *
 * @return null
 */
static void validateSamplesheet(params, log) {
    if (params.samplesheet) {
        log.info "Using samplesheet '${params.samplesheet}'"
    } else {
        log.error "Parameter 'samplesheet' is required but was not provided."
        System.exit(64)
    }
}


/**
 * Validate trim tool.
 *
 * Check that trim tool param exists and is a valid trim tool.
 * Throw exit status 64 if otherwise.
 *
 * @param params The params for the Nextflow pipeline.
 * @param log The Nextflow log object.
 *
 * @return null
 */
static void validateTrimTool(params, log) {
    if (params.tools.trim) {
        if (Tools.Trim.isTrimTool(params.tools.trim)) {
            log.info "Using trim tool '${params.tools.trim}'"
        } else {
            log.error "'${params.tools.trim}' is not a valid trim tool."
            System.exit(64)
        }
    } else {
        log.error "Parameter 'tools.trim' is required but was not provided."
        System.exit(64)
    }
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
