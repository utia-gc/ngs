---
title: Quick start - Local
layout: default
parent: Quick Start
---

# Quick start - Local
{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Problem

How do I download and run the pipeline on my local machine?

Bioinformatics pipelines should be as easy to download and start using as possible.
We have designed `utia-gc/ngs` and pipelines built on `utia-gc/ngs` to take full advantage of the deployment options built in to Nextflow and GitHub.

## Solution

Once a user has a working installation of Nextflow and preferably Apptainer (previously called Singularity), they can download, run, and manage the pipeline using only Nextflow commands.
This makes usage and management of the pipeline extremely simple.

## Usage

### Prerequisites

1. Any POSIX compatible system (e.g. Linux, OS X, etc) with internet access

    Run on Windows with [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/). WSL2 highly recommended.

1. [Nextflow](https://www.nextflow.io/) version >= 23.09.2

    See [Nextflow Get started](https://www.nextflow.io/docs/latest/getstarted.html#) for prerequisites and instructions on installing and updating Nextflow.

1. [Apptainer](https://sylabs.io)

    This is not a strict requirement as the pipeline should technically run so long as necessary versions of all of the tools used are available on the `PATH`.
    However, this is probably not the case.
    And in the rare event that all required tools are available, this is likely extremely fragile and is ultimately counterproductive to pipeline's goal of reproducibility.

    So in short: just use Apptainer.

### Download or update pipeline

1. Download or update `utia-gc/ngs`:

    ```bash
    nextflow pull utia-gc/ngs
    ```

    Downloading the pipeline using the `nextflow pull` command stores a local copy in a hidden directory on the user's system (it should be in `~/.nextflow/assets`).
    Downloading the pipeline in this way means that it can be managed entirely by referencing the repository name (i.e. `utia-gc/ngs`).
    There's no need to worry about details like what directory the pipeline is stored in, where the most recent version is kept, or any of the usual headaches that come along with keeping track of scripts.
    Nextflow is able to take care of all of this for us.

2. Show pipeline info such as default and available revisions:

    ```bash
    nextflow info utia-gc/ngs
    ```

### Test `utia-gc/ngs`

`-revision main` uses a specific version of the pipeline --- in Nextflow terminology, revision means pipeline version.
`-profile nf_test` uses preconfigured test parameters to run `utia-gc/ngs` in full on a small test dataset stored in a remote GitHub repository. Apptainer containers are used in the run.
Because these test files are stored in a remote repository, internet access is required to run the test.
For more information, see the `profiles` section of the [config file](nextflow.config).

```bash
nextflow run utia-gc/ngs \
    -revision main \
    -profile nf_test
```

{: .important }
> In accordance with best practices for reproducible analysis, always use the `-revision` option in `nextflow run` to specify a tagged and/or released version of the pipeline.
>
> A branch name like `main` is usually a poor choice of revision since it isn't a specifically tagged version number or commit ID, but `utia-gc/ngs` is not meant to have released revisions so we make do with what we have for the purposes of these docs.
