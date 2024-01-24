/**
 * Represents the options of tools available for different steps.
 */
class Tools {

    /**
     *  Enum representing tools for trimming/filtering reads.
     */
    enum Trim {
        CUTADAPT,
        FASTP

        /**
         * Check if a given tool name matches a valid trim tool.
         *
         * @param tool The tool to check for.
         * @return true if the tool matches any valid trim tool, otherwise false.
         */
        static boolean isTrimTool(String tool) {
            return values().any {it.name().equalsIgnoreCase(tool)}
        }
    }


    /**
     *  Enum representing tools for mapping reads.
     */
    enum Map {
        BWAMEM2,
        STAR

        /**
         * Check if a given tool name matches a valid map tool.
         *
         * @param tool The tool to check for.
         * @return true if the tool matches any valid map tool, otherwise false.
         */
        static boolean isMapTool(String tool) {
            return values().any {it.name().equalsIgnoreCase(tool)}
        }
    }
}
