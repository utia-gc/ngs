# Development

## Style conventions

It would be handy to be able to differentiate between modules, subworkflow, and workflows at a glance.
To make that happen, use the following naming conventions that imply a hierarchy:

- Modules: lower_snake_case
  - Example: `#!groovy samtools_sort`
- Subworkflow: Pascal_Snake_Case
  - Example: `#!groovy Prepare_Refs`
- Workflow: UPPER_SNAKE_CASE
  - Example: `#!groovy PROCESS_READS`

## Testing

Use the [`nf-test`][nf_test_page] framework for testing.

### What to test

Ideally, all processes, subworkflows, workflows, and pipelines should be tested.
I (Trevor) am a proponent of test-driven (specifically behavior-driven) development, which means most everything will be tested as it is implemented.
In order to simplify testing, I highly recommend a strategy something like the following:

- Processes
  - Test processes for a combination of possible inputs to make sure it behaves as expected.
  - Test that processes emit the expected channels.
  - Do not test that processes produce expected files in the proper publish directories. This behavior should be tested at the workflow and pipeline levels.
- Subworkflows
  - Same recommendations as processes.
- Workflows
  - Test workflows for a combination of possible inputs and parameters used in workflows.
    - If subworkflows or processes can be skipped or behavior relies on parameters (e.g. allowed tools) make sure that it works here.
  - Test that workflows emit the expected channels.
  - Test that expected files are produced in the proper publish directories.
  - This is generally where the most extensive testing should be done - if workflows behave as expected then ideally so will the subworkflows and processes that comprise them as well the pipelines that they comprise.
- Pipelines
  - Test that the expected number of tasks succeed.
  - Test that the pipeline fails if given conditions for which it should fail.
  - Test tat expected files are produced in the proper publish directories.

[nf_test_page]: https://code.askimed.com/nf-test/
