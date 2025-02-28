# Project setup
## Setup pipeline files
nf_setup_params := config/nextflow/params_setup.yaml
nf_setup_config := config/nextflow/setup.config
nf_setup_script := src/sbatch/nf_run_setup.sh
## Setup input file(s)
sample_decode := config/samplesheets/sample-name-decode.csv
## Setup output samplesheet
samplesheet := config/samplesheets/samplesheet.csv

.PHONY: all
all: setup

.PHONY: setup
setup: $(samplesheet)
	@echo "Ran project setup"

$(samplesheet): .cache/nf_logs/setup.log
	@touch $(samplesheet)

.cache/nf_logs/setup.log: $(setup_params) $(setup_config) $(sample_decode) $(setup_script)
	@echo "Run setup script"
	@sbatch --wait --verbose $(setup_script)
