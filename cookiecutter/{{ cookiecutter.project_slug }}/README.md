# {{ cookiecutter.project_name }}

## Author

{{ cookiecutter.author }} --- {{ cookiecutter.email }}

## Purpose

{{  cookiecutter.project_purpose }}

## Directory structure

```text
{{ cookiecutter.project_slug }}
├── config                                       <- Directory for all configs and params files
│   ├── nextflow.config
│   ├── params_ngs.yaml
│   └── params_setup.yaml
├── data                                         <- Directory for all raw and final data
│   └── samplesheets                             <- Directory for samplesheets, decodes, column data, etc.
│       └── decode.csv                           <- Decode sheet used with setup.nf.
├── src                                          <- Directory for all source code
│   └── sbatch
│       ├── nf_run_ngs.sh
│       └── nf_run_setup.sh
└── README.md                                    <- Top-level README for the project
```
