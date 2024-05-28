# Project setup

## Problem

How should I setup my project?

Many bioinformatics pipelines tend to work best when projects are setup in a specific manner, i.e. when certain files are present and when there is a specific directory structure.
This is not the case for `{{ pipeline.name }}` and pipelines built on `utia-gc/ngs`.
The pipeline does not assume or require any default directory structure or locations for specific files -- these are all supplied at runtime as [params or config options](./required_params.md).
Ironically, we find that not requiring a specific project setup leads many of us with a new issue -- if all the required inputs can go anywhere, then what's a good place to put them?

Even without this analysis paralysis, setting up a new project involves a lot of repetitive work that is susceptible to all sorts of human error and could easily be abstracted away and automated.

## Solution

In order to alleviate analysis paralysis and handle repetitive work, we provide two *optional* but highly recommended tools.

First is [cookiecutter][cookiecutter_home], which sets up a new project skeleton from a template.
This will initialize a new project directory with our favored directory structure and naming scheme.
The project directory that is created contains a convenient README file and scripts for submitting both Nextflow setup and main scripts as jobs to the ISAAC SLURM scheduler.
In addition, it has template Nextflow config files and params for running the project setup script (described below).
Even if the user does not intend to use the project directory as it is setup in the template, we find that this template is informative for seeing what files the pipeline expects and how to configure runs the of the main pipeline.

Second is a convenient Nextflow script (`setup.nf`) for copying data files into the project directory and setting up the [samplesheet](./samplesheet_format.md) that provides pipeline inputs.

Both of these tools are packaged with the pipeline code in order to limit external dependencies and keep the tools immediately useable and in-line with their respective pipeline revisions.

## Usage

As stated above, setting up your projects in this way is completely optional, and either of these steps can be run independently of the other.
However, we highly recommended using both tools in the two simple steps outline here.

1. Setup the project directory from the pipeline repo with Cookiecutter:

    ``` bash title="Terminal"
    cookiecutter gh:{{ pipeline.name }} --directory cookiecutter --checkout {{ pipeline.revision }}
    ```

2. Run the project setup Nextflow script:

    ```bash title="Terminal"
    nextflow run {{ pipeline.name }} \
        -main-script setup.nf \
        -revision {{ pipeline.revision }} \
        -params-file src/nextflow/setup_params.yaml
    ```

### Cookiecutter project template

Using the Cookiecutter project template is very straightforward.
The only requirement is an existing Cookiecutter installation on your path.
We recommend following the installation instructions using pip inside a virtual environment as dictated by Python best practices.

1. [Install Cookiecutter][cookiecutter_docs_install]

2. Setup the project directory from the pipeline repo with Cookiecutter:

    ``` bash title="Terminal"
    cookiecutter gh:{{ pipeline.name }} --directory cookiecutter --checkout {{ pipeline.revision }}
    ```

    Simply follow the prompts and your project directory will be created.

### Nextflow setup pipeline

1. Install or update the latest pipeline revision:

    ``` bash title="Terminal"
    nextflow pull {{ pipeline.name }}
    ```

2. Run the project setup Nextflow script:

    ``` bash title="Terminal"
    nextflow run {{ pipeline.name }} \
        -main-script setup.nf \
        -revision {{ pipeline.revision }} \
        -params-file src/nextflow/setup_params.yaml
    ```

[cookiecutter_home]: https://www.cookiecutter.io/
[cookiecutter_docs_install]: https://cookiecutter.readthedocs.io/en/latest/README.html#installation
