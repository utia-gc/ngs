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

## Make a local clone of your pipeline repository

To effectively edit your pipeline, make a local clone of your pipeline's repository on the computer where you will develop your pipeline (your development environment).

1. Copy your pipeline URL -- Click the green `Code` button in the top right of your pipeline repo code page and copy the URL.
I typically use the HTTPS.
2. Open a terminal session in your development environment and navigate to the directory where you want to create the clone of your pipeline repo.
3. Clone your pipeline repo:

    ``` bash title="Terminal"
    git clone --recurse-submodules <repository-URL>
    ```

    !!! note "`--recurse-submodules`"

        All local test data is located in `tests/data` which is setup as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules).
        Supplying the `--recurse-submodules` argument to `git clone` will clone the correct repository into `tests/data` so that you can run tests.

        If you don't clone submodules at this step it's possible to do this later, but it's easier to do it at this project setup unless you have a reason not to.

## Change pipeline name

One of the first changes that needs to be made is updating the pipeline name throughout the repo.

In most places this isn't strictly necessary as the repository name is primarily found in comments and the docs, but it's still best to update it at this point, otherwise you'll probably forget to update it ever which will create confusion down the line.

How exactly you do this depends on your environment and what you find easiest.
I typically in the IDE VS Code, and I like the Find in file feature that it has available in the file explorer paine for searching and replacing.
`grep`ping for the old repo name and manually editing files is another fine solution.

!!! warning "Don't blindly find and replace"

    I very explicitly recommend not doing a blind, automated search and replace with a tool like `sed` or in the IDE of your choice.
    You never know what exactly is being found and replaced in those cases, so you can accidentally break something.
    For example, if you blindly replace all instances of `ngs` in your repo with `atacseq` then an important reference to a `settings.config` file would instead reference `settiatacseq.py` and wreak who knows what havoc.

    Take a few minutes to do things by hand -- it's better to set things up correctly to begin with.

## Setup virtual environment

Developing your pipeline will involve a few Python tools, and Python best practices demands the use of virtual environments.

1. Create the virtual environment.
I recommend using the `venv` module to create a virtual environment in the `.venv` directory.
This module does everything we need and ships with Python and therefore doesn't require any additional installations.

    ``` bash title="Terminal"
    python3 -m venv .venv
    ```

2. Activate the virtual environment.
You should activate your virtual environment every time you develop in this repository.
A good IDE like VS Code can handle this for you so that activation is automated.

    ``` bash title="Terminal"
    source .venv/bin/activate
    ```

3. Install packages into the virtual environment
Now that your virtual environment is setup, all that's left to do is install the necessary packages in your environment so that you can use them.
This is easy to do with the `requirements.txt` that is forked and cloned inside your new pipeline repo.

    ``` bash title="Terminal"
    python3 -m pip install -r requirements.txt
    ```
