# Resource limits

## Problem

How do I change the resource limitations of the pipeline?

Different systems and variations of pipelines will require different computational resources, e.g. numbers of CPUs, amounts of memory, and time.
Capping resource usage so that jobs don't fail for requesting more than the system can reserve is an important way to keep pipelines useful across a variety of computing systems.

## Solution

As of version 24.04.0, Nextflow makes it easy to cap resource requests through use of the [`resourceLimits` process directive](https://www.nextflow.io/docs/latest/reference/process.html#resourcelimits).

## Usage

To set resource limits for a pipeline run, simply set the `resourceLimits` process directive in a Nextflow configuration file, and pass that configuration file to the pipeline run:

``` groovy title="nextflow.config"
process {
    /*
    Resource request configs
    */
    resourceLimits = [
        cpus:   12,
        memory: 32.GB,
        time:   48.hour
    ]
}
```

``` bash title="Terminal"
nextflow run {{ pipeline.name }} \
   -revision {{ pipeline.revision }} \
   -config nextflow.config
```
