# Create New Pipeline

`{{ pipeline.name }}` and pipelines built on `utia-gc/ngs` are meant to be readily and easily extensible to facilitate quick development of pipelines for processing NGS data.
This document provides recommendations for creating a new pipeline based on `{{ pipeline.name }}`.

## Fork the pipeline repository

The easiest way to create a new pipeline is to make a fork of the existing pipeline on GitHub.

1. Navigate to the [pipeline's GitHub repository](https://github.com/{{ pipeline.name }})
2. Check to see if a pipeline matching your needs already exists -- Click the arrow next to the Fork button in the top right corner of the page to show a list of all the pipelines associated with `{{ pipeline.name }}`.
3. If you need to create a new pipeline, click the `Create a new fork` button below the dropdown list or just the `Fork` button at the top right of the repo code page.
    Note this requires a GitHub account.
    If you aren't logged in you will be redirected to the login page where you must either login or create a GitHub account if you don't have one already.
4. Follow the prompts to create your fork with your desired pipeline name and description.
    I recommend only copying the `main` branch, which should be selected by default.
