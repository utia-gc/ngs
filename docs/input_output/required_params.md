# Required params

## Problem

What params do I need to run the pipeline?

Bioinformatics pipelines require input of user data and settings.
We have designed `{{ pipeline.name }}` and pipelines built on `utia-gc/ngs` to require limited params that are simple to specify.

## Solution

We identified a few types of information that users must supply to be able to run the pipeline:

* Input sample files
  * `samplesheet` -- Sample files and metadata [formatted as a structured CSV file](./samplesheet_format.md)
* Reference assembly information
  * `genome` -- A URL or path to a reference genome fasta file. May be gzip compressed.
  * `annotations` -- A URL path to a reference annotations GTF file. May be gzip compressed.

## Usage
