# Outputs

## A note on terminology

In Nextflow parlance, output files that are written to specified directories by Nextflow are said to be "published."
We will stick with this terminology here for the sake of consistency.
That is, files produced by tasks within the pipeline and written to subdirectories of the Nextflow working directory are called "output files".
Output files that are published to a specified folder are called "published files".

[Nextflow `#!groovy publishDir` docs][publishDir_docs]

## Publish directories

The purpose of this pipeline is two-fold:
first, to perform necessary data processing steps on NGS data, and
second, to report important quality control metrics for the NGS data and the processing steps performed here.

As such, we feel that it makes sense to publish the results to different directories based on which of these two purposes they fulfill.
Data files are published to subdirectories within the directory specified in the parameter `#!groovy publishDirData`.
We consider data files to be those files which would be indespensible for reanalysis or continued analysis, e.g. fastq files of trimmed and concatenated reads, coordinate sorted BAM files, counts matrices of reads within genes, etc.
Reports files are published to subdirectories within the directory specific in the parameter `#!groovy publishDirReports`.
We consider reports files to be those files which are either reports themselves (MultiQC reports, FastQC reports, etc.) or files that are directly used to make QC reports and are of limited utility elsewhere (e.g. MultiQC data, FastQC zip data, logs from alignment or trimming tools, Samtools flagstat, etc.).

[publishDir_docs]: https://www.nextflow.io/docs/latest/process.html#publishdir
