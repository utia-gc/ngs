# `utia-gc/ngs`

[![nf-test](https://img.shields.io/badge/tested_with-nf--test-337ab7.svg)](https://code.askimed.com/nf-test)
[![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

:book:[Full documentation on GitHub Pages]:book:

## Introduction

`utia-gc/ngs` is a [Nextflow](https://www.nextflow.io/) pipeline for base NGS analysis.
While `utia-gc/ngs` can be run on any platform supported by Nextflow, it is developed for use in HPC environments and specifically [ISAAC Next Generation] at the University of Tennessee, Knoxville.

> [!WARNING]
> It is usually not a good idea to directly run `utia-gc/ngs`. This pipeline is designed to be a starting point for pipelines dedicated to specific analyses. It is generally not meant to be run itself. It will not often have scheduled or tagged releases, and as such it cannot reliably be used reproducibly. In nearly all cases, users should check the forked repos to find a pipeline built from `utia-gc/ngs` that is more suited to their needs or fork the repo to create their own versioned releases of a pipeline built on `utia-gc/ngs`.

### Pipeline overview

```mermaid
flowchart LR
    %% list all the input files
    samplesheet>"Samplesheet"]
    genome_fasta>"
        Genome
        FASTA
    "]
    annotations_gtf>"
        Annotations
        GTF
    "]

    %% list all the internal Nextflow channels
    raw_reads[("
        Raw
        reads
    ")]
    prealign_reads[("
        Prealign
        reads
    ")]
    trim_log[("
        Trim
        log
    ")]
    individual_alignments[("
        Individual
        alignments
    ")]
    merged_alignments[("
        Merged
        alignments
    ")]

    %% list all the Nextflow processes
    fastp{"fastp"}
    cutadapt{"cutadapt"}
    fastqc{"FastQC"}
    seq_depth{"
        Sequencing
        Depth
    "}
    bwa_mem2{"bwa-mem2"}
    STAR{"STAR"}
    samtools_sort{"
        samtools
        sort
        index
    "}
    gatk_MergeSamFiles{"
        gatk
        MergeSamFiles
    "}
    gatk_MarkDuplicates{"
        gatk
        MarkDuplicates
    "}
    samtools_idxstats{"
        samtools
        idxstats
    "}
    samtools_flagstat{"
        samtools
        flagstat
    "}
    samtools_stats{"
        samtools
        stats
    "}

    %% list all subgraphs for Nextflow subworkflows/workflows with options
    subgraph inputs["Input Files"]
    samplesheet
    genome_fasta
    annotations_gtf
    end
    subgraph trim_reads["Trim Reads"]
    fastp
    cutadapt
    end
    subgraph map_reads["Map Reads"]
    bwa_mem2
    STAR
    end
    subgraph publish_reports["Publish Reports"]
    reads_mqc
    alignments_mqc
    full_mqc
    end
    subgraph publish_data["Publish Data"]
    alignments
    end

    %% list all the published reports files
    reads_mqc((("
        Reads
        MultiQC
    ")))
    alignments_mqc((("
        Alignments
        MultiQC
    ")))
    full_mqc((("
        Full MultiQC
    ")))

    %% list all the published data files
    alignments[["
        Alignments
    "]]

    %% reads processing workflow
    samplesheet --> raw_reads
    raw_reads --- trim_reads --> prealign_reads

    %% reads QC workflow
    raw_reads --- fastqc --x reads_mqc
    prealign_reads --- fastqc --x reads_mqc
    trim_reads --> trim_log --x reads_mqc
    raw_reads --- seq_depth --x reads_mqc
    prealign_reads --- seq_depth --x reads_mqc

    %% reads mapping workflow
    genome_fasta --- map_reads
    annotations_gtf --- map_reads
    prealign_reads --- map_reads

    %% alignments processing workflow
    map_reads --- samtools_sort --> individual_alignments
    individual_alignments --- gatk_MergeSamFiles --- gatk_MarkDuplicates --> merged_alignments
    merged_alignments --x alignments

    %% alignments QC workflow
    individual_alignments --- samtools_idxstats --x alignments_mqc
    individual_alignments --- samtools_flagstat --x alignments_mqc
    merged_alignments --- samtools_stats --x alignments_mqc

    %% Full MultiQC
    reads_mqc --x full_mqc
    alignments_mqc --x full_mqc
```

## Quick start

### Prerequisites

1. Any POSIX compatible system (e.g. Linux, OS X, etc) with internet access

   - Run on Windows with [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/). WSL2 highly recommended.

2. [Nextflow](https://www.nextflow.io/) version >= 21.04

   - See [Nextflow Get started](https://www.nextflow.io/docs/latest/getstarted.html#) for prerequisites and instructions on installing and updating Nextflow.

3. [Singularity](https://sylabs.io)

### Get or update `utia-gc/ngs`

1. Download or update `utia-gc/ngs`:

    ```bash
    nextflow pull utia-gc/ngs
    ```

2. Show project info:

    ```bash
    nextflow info utia-gc/ngs
    ```

### Test `utia-gc/ngs`

1. Check that `utia-gc/ngs` works on your system:

   - `-profile nf_test` uses preconfigured test parameters to run `utia-gc/ngs` in full on a small test dataset stored in a remote GitHub repository.
   - Because these test files are stored in a remote repository, internet access is required to run the test.
   - For more information, see the `profiles` section of the [nextflow config file](nextflow.config).

   ```bash
   nextflow run utia-gc/ngs \
      -revision main \
      -profile nf_test
   ```

> [!IMPORTANT]
> In accordance with best practices for reproducible analysis, always use the `-revision` option in `nextflow run` to specify a tagged and/or released version of the pipeline.

### Run `utia-gc/ngs`

TODO

[Full documentation on GitHub Pages]: https://utia-gc.github.io/ngs/
