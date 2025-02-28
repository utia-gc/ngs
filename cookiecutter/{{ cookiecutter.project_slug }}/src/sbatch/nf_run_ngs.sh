#!/bin/bash
#SBATCH --job-name={{ cookiecutter.project_slug }}_ngs
#SBATCH --cpus-per-task=1
#SBATCH --mem=3GB
#SBATCH --time=03-00:00:00
#SBATCH --error=.cache/sbatch_logs/%j_-_%x.err
#SBATCH --output=.cache/sbatch_logs/%j_-_%x.out
#SBATCH --account={{ cookiecutter.slurm_account }}
#SBATCH --partition={{ cookiecutter.slurm_partition }}
#SBATCH --qos={{ cookiecutter.slurm_qos }}
#SBATCH --mail-user={{ cookiecutter.email }}
#SBATCH --mail-type=END,FAIL


set -u
set -e

#######################################
# Constants
#######################################
# pipeline revision to use
readonly revision="{{ cookiecutter.pipeline_revision }}"

# set nextflow options for execution via slurm
export NXF_OPTS="-Xms500M -Xmx2G"
export NXF_ANSI_LOG=false

# install/update the pipeline
nextflow \
    pull \
        -revision "${revision}" \
    utia-gc/ngs

# run pipeline
nextflow -log .cache/nf_logs/ngs.log \
    run \
        -revision "${revision}" \
        -profile condo_trowan1,exploratory \
        -config config/nextflow/ngs.config \
        -params-file config/nextflow/params_ngs.yaml \
    utia-gc/ngs
