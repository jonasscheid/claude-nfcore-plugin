---
name: open-issue
description: Open an issue on an nf-core pipeline repository using the standard nf-core issue templates (bug report or feature request). Use when the user wants to file an issue, report a bug, request a feature, or create a GitHub issue.
---

# Open nf-core Issue

Create a GitHub issue on an nf-core pipeline repository using the standard nf-core issue templates.

## Issue Templates

### Bug Report Template

The bug report template has these exact fields. The issue body MUST follow this structure:

```yaml
name: Bug report
description: Report something that is broken or incorrect
labels: bug
body:
  - type: markdown
    attributes:
      value: |
        Before you post this issue, please check the documentation:

        - [nf-core website: troubleshooting](https://nf-co.re/usage/troubleshooting)
        - [nf-core/mhcquant pipeline documentation](https://nf-co.re/mhcquant/usage)
  - type: textarea
    id: description
    attributes:
      label: Description of the bug
      description: A clear and concise description of what the bug is.
    validations:
      required: true

  - type: textarea
    id: command_used
    attributes:
      label: Command used and terminal output
      description: Steps to reproduce the behaviour. Please paste the command you used to launch the pipeline and the output from your terminal.
      render: console
      placeholder: |
        $ nextflow run ...

        Some output where something broke

  - type: textarea
    id: files
    attributes:
      label: Relevant files
      description: |
        Please drag and drop the relevant files here. Create a `.zip` archive if the extension is not allowed.
        Your verbose log file `.nextflow.log` is often useful _(this is a hidden file in the directory where you launched the pipeline)_ as well as custom Nextflow configuration files.

  - type: textarea
    id: system
    attributes:
      label: System information
      description: |
        * Nextflow version _(eg. 23.04.0)_
        * Hardware _(eg. HPC, Desktop, Cloud)_
        * Executor _(eg. slurm, local, awsbatch)_
        * Container engine: _(e.g. Docker, Singularity, Conda, Podman, Shifter, Charliecloud, or Apptainer)_
        * OS _(eg. CentOS Linux, macOS, Linux Mint)_
        * Version of nf-core/mhcquant _(eg. 1.1, 1.5, 1.8.2)_
```

### Feature Request Template

The feature request template has this exact field:

```yaml
name: Feature request
description: Suggest an idea for the nf-core/mhcquant pipeline
labels: enhancement
body:
  - type: textarea
    id: description
    attributes:
      label: Description of feature
      description: Please describe your suggestion for a new feature. It might help to describe a problem or use case, plus any alternatives that you have considered.
    validations:
      required: true
```

## Process

### Step 1: Determine Issue Type

Ask the user (if not provided) which type of issue to create:

1. **Bug report** — Something is broken or incorrect
2. **Feature request** — Suggest an idea for the pipeline

### Step 2: Detect Repository

Detect the pipeline name and repository from:
- `manifest.name` in `nextflow.config`
- The git remote URL of the current working directory
- Fall back to asking the user if not in a pipeline directory

Replace `mhcquant` in template URLs/references with the actual pipeline name.

### Step 3: Collect Information Based on Template

#### For Bug Reports

Collect information matching the exact template fields:

1. **Description of the bug** (required) — Ask the user for a clear and concise description of what the bug is.

2. **Command used and terminal output** (optional) — Ask for the command they ran and relevant terminal output. If the user mentions a `.nextflow.log` or error output file, offer to read it.

3. **Relevant files** (optional) — Ask if there are relevant log files or configuration files to mention.

4. **System information** (optional but recommended) — Auto-detect where possible, ask for the rest:
   - Nextflow version: run `nextflow -version` to get it automatically
   - Hardware (HPC, Desktop, Cloud): ask user
   - Executor (slurm, local, awsbatch): ask user
   - Container engine (Docker, Singularity, Conda, Podman, Shifter, Charliecloud, or Apptainer): ask user
   - OS: auto-detect from system
   - Pipeline version: check `manifest.version` in `nextflow.config` if available

#### For Feature Requests

Collect the single required field:

1. **Description of feature** (required) — Ask the user to describe their suggestion for a new feature. Prompt them to include the problem or use case, plus any alternatives they have considered.

### Step 4: Create the Issue

Use `gh issue create` with the body structured to match the template fields exactly.

**Bug report:**

```bash
gh issue create \
  --title "<title>" \
  --label "bug" \
  --body "$(cat <<'EOF'
## Description of the bug

<user-provided description>

## Command used and terminal output

```console
<command and output if provided>
```

## Relevant files

<files info if provided>

## System information

* Nextflow version: <version>
* Hardware: <hardware>
* Executor: <executor>
* Container engine: <engine>
* OS: <os>
* Version of nf-core/<pipeline>: <version>
EOF
)"
```

**Feature request:**

```bash
gh issue create \
  --title "<title>" \
  --label "enhancement" \
  --body "$(cat <<'EOF'
## Description of feature

<user-provided description>
EOF
)"
```

### Step 5: Return the Issue URL

Return the created issue URL to the user.

## Important Rules

- **Use the exact template field names** as section headers (e.g., "Description of the bug", not "Bug Description")
- **Use the correct labels**: `bug` for bug reports, `enhancement` for feature requests
- **Auto-detect system information** where possible (Nextflow version, OS, pipeline version)
- **Replace pipeline name** in the template (e.g., `mhcquant`) with the actual pipeline name from the repo
- **Never include "Generated with Claude Code" or any Claude citation** in the issue body
- **Ask for all required fields** before creating the issue
- **Omit empty optional sections** rather than leaving blank headers
