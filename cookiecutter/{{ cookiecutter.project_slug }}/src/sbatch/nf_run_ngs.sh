#!/bin/bash
#SBATCH --job-name={{ cookiecutter.project_slug }}_ngs
#SBATCH --error=job_logs/%x.e%j
#SBATCH --output=job_logs/%x.o%j
#SBATCH --mail-user={{ cookiecutter.email }}
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --account={{ cookiecutter.slurm_account }}
#SBATCH --partition={{ cookiecutter.slurm_partition }}
#SBATCH --qos={{ cookiecutter.slurm_qos }}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=01-00:00:00


set -u
set -e

# set nextflow options for execution via slurm
export NXF_OPTS="-Xms500M -Xmx2G"
export NXF_ANSI_LOG=false

# install/update the pipeline
nextflow pull utia-gc/ngs

# run pipeline
nextflow run utia-gc/ngs \
    -revision main \
    -profile condo_trowan1,exploratory \
    -config config/nextflow.config \
    -params-file config/params_ngs.yaml
