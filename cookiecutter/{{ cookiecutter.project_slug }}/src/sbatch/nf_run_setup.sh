#!/bin/bash
#SBATCH --job-name={{ cookiecutter.project_slug }}_setup
#SBATCH --error=job_logs/%x.e%j
#SBATCH --output=job_logs/%x.o%j
#SBATCH --mail-user={{ cookiecutter.email }}
#SBATCH --mail-type=END,FAIL
#SBATCH --account={{ cookiecutter.slurm_account }}
#SBATCH --partition={{ cookiecutter.slurm_partition }}
#SBATCH --qos={{ cookiecutter.slurm_qos }}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00-02:00:00


set -u
set -e

# set nextflow options for execution via slurm
export NXF_OPTS="-Xms500M -Xmx2G"
export NXF_ANSI_LOG=false

# install/update the pipeline
nextflow pull utia-gc/ngs

# run pipeline
nextflow run utia-gc/ngs \
    -main-script setup.nf \
    -revision main \
    -profile condo_trowan1 \
    -params-file src/nextflow/params_setup.yaml
