# Arguments to processes

## Problem

How do I run a step of the pipeline with the command line arguments that I want to use?

Bioinformatics pipelines should have reasonable default arguments but ultimately be fully configurable by the user.
We have designed `{{ pipeline.name }}` and pipelines built on `utia-gc/ngs` to make handling command line arguments user-friendly, predictable, and robust.

## Solution

We identified three levels at which configurable process-level arguments should be specified:

1. *Default arguments* -- Arguments built into the pipeline that we find reasonable or deem to be a good starting point.
2. *Dynamic arguments* -- Arguments determined by the pipeline at runtime. For example, a user analyzing an RNA-seq experiment where libraries are a mix of single-end and paired-end reads may want their pipeline run's read counting step to run in single- or paired-end mode depending on the type of library provided.
3. *User arguments* -- Arguments specified by the user.

A key consideration built in to `{{ pipeline.name }}` is that arguments at each successive level should add to the arguments of the level above it, and if the same argument is supplied at multiple levels, the lower level should take precedence.
Concretely, the order of precedence is as follows: user > dynamic > default.

To illustrate this idea, consider a process for counting reads within features using a made up tool.
The following three argument levels are set:

1. Default arguments -- `--ends single --verbose 0`
2. Dynamic arguments -- `--ends paired --stranded 1`
3. User arguments -- `--verbose 2 --feature exon --stranded 0`

`utia-gc/ngs` solves this collection of arguments so that the arguments that are finally used in the command are: `--ends paired --verbose 2 --stranded 0 --feature exon`.
Here are the arguments that we had after each step of merging:

1. Default -- `--ends single --verbose 0`
2. Dynamic > default -- `--ends paired --verbose 0 --stranded 1`
3. User > dynamic > default -- `--ends paired --verbose 2 --stranded 0 --feature exon`

## Usage

The three levels of arguments are specified as [Groovy map objects][nextflow_groovy_maps_docs] in the special [`ext` process directive][ext_process_directive_docs] associated with a specific process name using Nextflow's [`withName` process selector][withName_process_selector_docs].
This allows each process to have its own set of arguments that can easily be specified using a [Nextflow configuration file][nextflow_configuration_docs].

You can see an example of how the default and dynamic arguments are specified in the pipeline's builtin [arguments configuration file][args_config].

### How to specify arguments

Let's use an example to demonstrate how to specify arguments -- the same example as the read counting tool from above.
In this example, the pipeline has the following builtin arguments in a configuration file:

``` groovy title="pipeline-directory/conf/args.config"
process {
    withName: 'foo' {
        ext.argsDefault = [
            '--ends': 'single',
            '--verbose': '0',
        ]
        ext.argsDynamic = [
            '--ends': "${metadata.readType}",
            '--stranded': metadata.stranded ? '1' : '0',
        ]
    }
}
```

The user can then specify their own arguments by adding arguments in their user configuration file:

``` groovy title="nextflow.config"
process {
    withName: 'foo' {
        ext.argsUser = [
            '--verbose': '2',
            '--stranded': '0',
            '--feature': 'exon',
        ]
    }
}
```

As stated above, `{{ pipeline.name }}` solves this collection of arguments (and transforms the `Map` to a `String` for its use in the command) so that the arguments that are finally used in the command are: `'--ends paired --verbose 2 --stranded 0 --feature exon'`.

Note (as explained further below) that because of the dynamic arguments, this is true for the case in which `metadata.readType == 'paired'`.
If `metadata.readType == 'single'`, then the arguments would be solved as: `'--ends single --verbose 2 --stranded 0 --feature exon'`.
This is the power of the dynamic arguments.

There are many things to point out here in this small example:

* The arguments are specified for the process named `foo` by using the [`withName` process selector][withName_process_selector_docs] in the [process scope][process_scope_docs] in a Nextflow configuration file.
* Default arguments are specified in a map of `String:String` using the special variable name `ext.argsDefault`.
* Similarly, dynamic arguments are specifed in a map of `String:String` using the special variable name `ext.argsDynamic`.
* Similarly, user arguments are specifed in a map of `String:String` using the special variable name `ext.argsUser`.
* The dynamic arguments map can use Groovy code to access objects *within the process scope* and set arguments dynamically.
  * For a less jargon heavy explanation, when the `foo` process runs for a sample, it uses the information associated with the run for that sample to determine arguments.
    * Example 1: Sample 'bar' has `metadata.readType == 'paired'`, then that part of its map will be `'--ends': 'paired'`.
    * Example 2: Sample 'buzz' has `metadata.stranded == false`, then that part of its map will be `'--stranded': '0'`.
      * This is an example of the [Groovy ternary operator][groovy_ternary_docs], which is essentially just a compact if/else branch.
  * This use of code and access of objects within the process scope is not specifc to `ext.argsDynamic` -- it can be done with any variable names within `ext`. However, we recommend reserving `ext.argsDynamic` for the use of this dynamic evaluation as a matter of convention so that it is easy to see where arguments that may be different for different samples are set.
* Trailing commas -- a comma after the last element in a map -- are allowed in Groovy, and we encourage their use. They don't do anything special, but their use can help avoid errors as in the case that additional arguments are added later, the user does not have to remember to add a comma before adding more elements to the map.
* By convention we recommend using full argument names instead of single letters when available. This drastically improves the readability of a project.

### Ideal usage -- Only change user args

Ideally, the default and dynamic arguments for a process are acceptable and need not be changed.

If the user does not desire to specify any additional arguments, then they do not need to take any action.
If no user arguments are specified for a process, then the process is simply run with the default and dynamic arguments -- the user arguments default to an empty map which will not overwrite any default or dynamic arguments.

[nextflow_groovy_maps_docs]: https://www.nextflow.io/docs/latest/script.html#maps
[ext_process_directive_docs]: https://www.nextflow.io/docs/latest/process.html#ext
[withName_process_selector_docs]: https://www.nextflow.io/docs/latest/config.html#process-selectors
[nextflow_configuration_docs]: https://www.nextflow.io/docs/latest/config.html
[args_config]: https://github.com/utia-gc/ngs/blob/main/conf/args.config
[process_scope_docs]: https://www.nextflow.io/docs/latest/config.html#scope-process
[groovy_ternary_docs]: https://groovy-lang.org/operators.html#_ternary_operator
