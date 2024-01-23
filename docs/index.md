---
title: Home
layout: home
nav_order: 1
---

# `utia-gc/rnaseq`

Welcome to the [utia-gc/rnaseq](https://github.com/utia-gc/rnaseq) documentation!

## Structure of the docs

These docs are mainly setup in a question and answer format, typically from the perspective of a user who has decided to run the pipeline and is asking themself a question starting with "How do I... ?"

In order to properly answer these questions, we will take on each in turn and state why it is a problem that we felt the need to address in our pipeline.
From there, we will describe the solution in as plain terms as possible so that the user has a mental model of what the pipeline is actually doing.
Where possible, we will also point to a place in the pipeline code where the solution is implemented; this way the user can compare their mental model of the solution with the way the solution is actually written.
Finally, we will give direction as to how the user can make use of our solution to ensure their pipeline run works as intended.

## Questions

### [Input / Output](input_output/input_output.md)

- [What params do I need to run the pipeline?](input_output/required_params.md)

- [How do I format the input samplesheet?](input_output/samplesheet_format.md)

- [What outputs will I get from the pipeline?](input_output/outputs.md)

### [Pipeline Configuration](pipeline_config/pipeline_config.md)

- [How do I run a step of the pipeline with the command line arguments that I want to use?](pipeline_config/arguments_to_processes.md)

- [How do I make it easier to try out and evaluate new params or arguments?](pipeline_config/exploratory_profile.md)

### [Contribute](contribute/contribute.md)

- [How can I contribute to the pipeline code or documentation?](contribute/development.md)

## Problems with code and docs

Since these docs are written and maintained by the pipeline developers, there will be many great questions from the users that need answers but which we haven't thought of asking.
In this case, please open a new issue in the [main repo issues page](https://github.com/utia-gc/rnaseq/issues) so that we can make sure the pipeline is useful to and usable by everyone.
There is no such thing as a dumb question!

We also kindly ask that you report any bugs you may come across and make any feature requests in the issues page as well.
