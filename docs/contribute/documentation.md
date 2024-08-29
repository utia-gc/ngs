# Documentation

Documentation should be included alongside development so that the project is kept in sync.

The documentation is built using [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).
This makes documentation easy to write, deploy, and manage as all docs are written in markdown files inside the `docs` directory.
Deployment is handled automatically by GitHub Actions and GitHub pages.

## Development

Writing docs should be simple.

In many cases, an existing page can simply be added to.
If a new page needs to be created, then simply create a new markdown file and include its path in the `nav` section of `/mkdocs.yml`.

In order to serve a test site during development, ensure a virtual environment with the necessary plugins is loaded and execute the following command:

``` bash title="Terminal"
mkdocs serve
```
