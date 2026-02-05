---
name: pipeline-create
description: Create a new nf-core pipeline from the official template. Use when starting a new pipeline project, setting up a new bioinformatics workflow, or when the user asks to create/initialize/scaffold a pipeline.
argument-hint: "[pipeline-name]"
disable-model-invocation: true
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Glob
---

# Create nf-core Pipeline

Generate a new Nextflow pipeline using the nf-core base template following community best practices.

## Quick Commands

```bash
# Interactive pipeline creation (recommended for first time)
conda run -n nf-core nf-core pipelines create

# Create with all options specified
conda run -n nf-core nf-core pipelines create \
    --name mypipeline \
    --description "My pipeline description" \
    --author "Your Name"

# Create using a template YAML file
conda run -n nf-core nf-core pipelines create --template-yaml template.yml

# Create with custom organization prefix
conda run -n nf-core nf-core pipelines create --org myorg
```

## Process

1. **Validate Pipeline Name**: Must be lowercase, no punctuation, descriptive
2. **Run Create Command**: Execute the interactive wizard or provide flags
3. **Select Template Features**: Choose which features to include/exclude
4. **Initialize Git**: Automatic git init with proper branches
5. **Push to GitHub**: Create empty repo and push initial commit

## Pipeline Naming Rules

- **Lowercase only**: `rnaseq` not `RNAseq`
- **No punctuation**: `methylseq` not `methyl-seq`
- **Descriptive**: Name should indicate data type or analysis
- **Unique**: Check existing pipelines at https://nf-co.re/pipelines

## Template Features (Selectable)

During creation, you can include/exclude:

| Feature | Description | Default |
|---------|-------------|---------|
| `github` | GitHub integration, CI tests, templates | Yes |
| `ci` | Continuous integration with linting | Yes |
| `github_badges` | README badges (CI status, DOI, etc.) | Yes |
| `igenomes` | iGenomes reference genome config | Yes |
| `nf_core_configs` | nf-core institutional configs | Yes |
| `code_linters` | Pre-commit hooks, Prettier | Yes |
| `citations` | CITATIONS.md file | Yes |
| `gitpod` | Gitpod development environment | No |
| `codespaces` | GitHub Codespaces support | No |
| `multiqc` | MultiQC report integration | Yes |
| `fastqc` | FastQC quality control module | Yes |
| `nf_schema` | nf-schema parameter validation | Yes |
| `slackreport` | Slack notifications | No |
| `adaptivecard` | Microsoft Teams notifications | No |

## Template YAML File

Create `template.yml` for reproducible pipeline creation:

```yaml
name: mypipeline
description: "A pipeline for analyzing XYZ data"
author: "Your Name"
org: nf-core  # or your organization

# Skip specific features
skip:
  - igenomes
  - slackreport
  - adaptivecard
  - gitpod

# Or explicitly include features
# features:
#   - github
#   - ci
#   - multiqc
```

## Generated Structure

```
nf-core-mypipeline/
├── .github/                  # GitHub Actions, templates
├── .devcontainer/            # Dev container config
├── assets/                   # Email templates, logos
├── bin/                      # Custom scripts
├── conf/                     # Configuration files
│   ├── base.config          # Base resource config
│   ├── modules.config       # Module-specific config
│   └── test.config          # Test profile config
├── docs/                     # Documentation
│   ├── output.md            # Output documentation
│   └── usage.md             # Usage documentation
├── lib/                      # Groovy libraries
├── modules/                  # nf-core modules
│   ├── local/               # Local modules
│   └── nf-core/             # Installed modules
├── subworkflows/            # Subworkflows
│   ├── local/               # Local subworkflows
│   └── nf-core/             # Installed subworkflows
├── workflows/               # Main workflow
├── main.nf                  # Entry point
├── nextflow.config          # Main config
├── nextflow_schema.json     # Parameter schema
├── CHANGELOG.md             # Version history
├── CITATIONS.md             # Tool citations
├── LICENSE                  # MIT License
└── README.md                # Pipeline README
```

## Git Branches

The template sets up three branches:
- `master` / `main`: Stable releases only
- `dev`: Active development
- `TEMPLATE`: Vanilla template for sync

## After Creation

1. **Create GitHub Repository**:
   ```bash
   # Create empty repo on GitHub (no README, no license)
   # Then push:
   cd nf-core-mypipeline
   git remote add origin git@github.com:username/nf-core-mypipeline.git
   git push -u origin --all
   ```

2. **Install Modules**:
   ```bash
   conda run -n nf-core nf-core modules install fastqc
   conda run -n nf-core nf-core modules install multiqc
   ```

3. **Run Lint**:
   ```bash
   conda run -n nf-core nf-core pipelines lint
   ```

4. **Test Pipeline**:
   ```bash
   nextflow run . -profile test,docker
   ```

## Important Notes

- Always discuss new pipeline proposals on nf-core Slack before development
- Check if similar pipeline exists: https://nf-co.re/pipelines
- Development starts on `dev` branch, not `master`
- PRs target `dev` branch for nf-core pipelines
