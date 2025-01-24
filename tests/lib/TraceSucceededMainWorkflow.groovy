/**
 * Make it easier to keep track of the number of successful traces in the main workflow.
 * 
 * @property constants       Integer number of tasks that don't vary based on number of inputs
 * @property nFastqPairs     Integer number of fastq pairs used as input to the pipeline
 * @property fastqPairsTasks Integer number of tasks that are executed once for each fastq file pair
 * @property nSamples        Integer number of samples used as input to the pipeline
 * @property samplesTasks    Integer number of tasks that are executed once for each sample
 */
class TraceSucceededMainWorkflow {
    Integer constants
    Integer nFastqPairs
    Integer fastqPairsTasks
    Integer nSamples
    Integer samplesTasks

    /**
     * Compute the total number of tasks expected to be successful for the trace.
     */
    public size() {
        Integer size = constants + (nFastqPairs * fastqPairsTasks) + (nSamples * samplesTasks)

        return size
    }
}
