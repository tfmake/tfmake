# tfmake

tfmake is a tool for automating Terraform with the power of make.

## Requirements

- bash 4+
- yq
- make

## Limitations

- To ensure an ordered execution, all dependencies between modules MUST be explicitly declared.
- Modules paths SHOULD NOT containt spaces; e.g. use `sample_module` instead `sample module`.

## Installation

### Git

```bash
git clone git@github.com:tfmake/tfmake.git
sudo cp -r tfmake/usr/local/* /usr/local/
sudo chmod +x /usr/local/bin/tfmake
```

## Usage

```
Usage:
  tfmake command [options] [args]

Available Commands:
  cleanup           Cleanup the data directory.
  config            Modify tfmake configuration.
  context           An alias for 'tfmake config' over the context value.
  init              Initialize the data directory for Terraform plan/apply execution.
  makefile          Generate a Makefile for Terraform plan/apply execution.
  mermaid           Generate a Mermaid flowchart diagram from Terraform modules and their dependencies.
  run               Run the Terraform plan/apply Makefile.
  summary           Create a Markdown summary.
  touch             Touch modified files.
  version           Show the current version.

GitHub Commands:
  gh-pr-comment     Add a comment to a GitHub pull request.
  gh-step-summary   Add content to GitHub Step Summary.

Other options:
  -h, --help, help  Print this help and exit.
  -v, --version     An alias for the "version" subcommand.
```

### Basic sequence of commands

```mermaid
flowchart LR

classDef primary fill:#a3cfbb,stroke:#a3cfbb,color:#136c44;
classDef secondary fill:#fee69b,stroke:#fee69b,color:#987405;

context("tfmake context")
init("tfmake init")
makefile("tfmake makefile")
touch("tfmake touch")
run("tfmake run")

context --> init --> makefile --> touch --> run

context:::primary
init:::primary
makefile:::primary
touch:::primary
run:::primary
```

### GitHub Actions commands

The commands `tfmake gh-step-summary` and `tfmake gh-pr-comment` are related to GitHub Actions.

## License

[MIT License](https://github.com/tfmake/tfmake/blob/main/LICENSE)
