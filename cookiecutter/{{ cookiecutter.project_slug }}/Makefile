# Project setup
## Setup pipeline files
nf_setup_config := config/nextflow/setup.config
nf_setup_params := config/nextflow/params_setup.yaml
nf_setup_script := src/sbatch/nf_run_setup.sh
## Setup input file(s)
sample_decode := config/samplesheets/sample-name-decode.csv
## Setup output samplesheet
samplesheet := config/samplesheets/samplesheet.csv
# Process data
## Data processing pipeline files
nf_ngs_config := config/nextflow/ngs.config
nf_ngs_params := config/nextflow/params_ngs.yaml
nf_ngs_script := src/sbatch/nf_run_ngs.sh


.PHONY: all
all: setup process

.PHONY: setup
setup: $(samplesheet)
	@echo "Ran project setup"

$(samplesheet): .cache/nf_logs/setup.log
	@touch $(samplesheet)

.cache/nf_logs/setup.log: $(sample_decode) $(nf_setup_config) $(nf_setup_params) $(nf_setup_script)
	@echo "Run project setup pipeline"
	@sbatch --wait --verbose $(nf_setup_script)

.PHONY: process
process: .cache/nf_logs/ngs.log
	@echo "Ran data processing"

.cache/nf_logs/ngs.log: $(samplesheet) $(nf_ngs_config) $(nf_ngs_params) $(nf_ngs_script)
	@echo "Run data processing pipeline"
	@sbatch --wait --verbose $(nf_ngs_script)
