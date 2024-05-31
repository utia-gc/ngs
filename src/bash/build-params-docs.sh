#!/usr/bin/env bash

readonly params_docs_path="docs/pipeline_config/params.md"

# build the docs page from the nf-schema (nf-validate) nextflow_schema.json file
nf-core schema docs --output "${params_docs_path}" --force

# replace the params docs file header with just "Params"
sed -i 's|utia-gc/ngs pipeline parameters|Params|g' "${params_docs_path}"
# the nf-core schema docs command uses three new-line characters to separate the param groups
# replace the three new-line characters with just a single new-line character
sed -i ':a;N;$!ba;s/\n\n\n/\n/g' "${params_docs_path}"
