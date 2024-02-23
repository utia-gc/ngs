---
title: Home
layout: home
nav_order: 1
---

# `utia-gc/ngs`

Welcome to the [utia-gc/ngs](https://github.com/utia-gc/ngs) documentation!

`utia-gc/ngs` is a [Nextflow](https://www.nextflow.io/) pipeline for base NGS analysis.
While `utia-gc/ngs` can be run on any platform supported by Nextflow, it is specifically developed for use on the [ISAAC Next Generation](https://oit.utk.edu/hpsc/isaac-open-enclave-new-kpb/) cluster at the University of Tennessee, Knoxville.

## Structure of the docs

{: .important }
> These docs assume at least a passing familiarity with some key Nextflow concepts.
> You will get much more out of these docs if you first read through the Nextflow documentation's [Getting started](https://www.nextflow.io/docs/latest/getstarted.html) and [Basic concepts](https://www.nextflow.io/docs/latest/basic.html) pages.

These docs are mainly setup in a question and answer format, typically from the perspective of a user who has decided to run the pipeline and is asking themself a question starting with "How do I... ?"

In order to properly answer these questions, we will take on each in turn and state why it is a problem that we felt the need to address in our pipeline.
From there, we will describe the solution in as plain terms as possible so that the user has a mental model of what the pipeline is actually doing.
Where possible, we will also point to a place in the pipeline code where the solution is implemented; this way the user can compare their mental model of the solution with the way the solution is actually written.
Finally, we will give direction as to how the user can make use of our solution to ensure their pipeline run works as intended.

## Questions

### [Quick Start](quick_start/quick_start.md)

- [How do I get and run the pipeline on my machine?](quick_start/local.md)

### [Input / Output](input_output/input_output.md)

- [What params do I need to run the pipeline?](input_output/required_params.md)

- [How do I format the input samplesheet?](input_output/samplesheet_format.md)

- [What outputs will I get from the pipeline?](input_output/outputs.md)

- [How should I setup my project?](input_output/project_setup.md)

### [Pipeline Configuration](pipeline_config/pipeline_config.md)

- [How do I run a step of the pipeline with the command line arguments that I want to use?](pipeline_config/arguments_to_processes.md)

- [How do I make it easier to try out and evaluate new params or arguments?](pipeline_config/exploratory_profile.md)

### [Contribute](contribute/contribute.md)

- [How can I contribute to the pipeline code or documentation?](contribute/development.md)

## Problems with code and docs

Since these docs are written and maintained by the pipeline developers, there will be many great questions from the users that need answers but which we haven't thought of asking.
In this case, please open a new issue in the [main repo issues page](https://github.com/utia-gc/ngs/issues) so that we can make sure the pipeline is useful to and usable by everyone.
There is no such thing as a dumb question!

We also kindly ask that you report any bugs you may come across and make any feature requests in the issues page as well.
