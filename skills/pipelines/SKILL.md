---
name: pipelines
description: Full nf-core pipeline lifecycle — create, lint, schema, sync, and release. Includes Nextflow strict syntax validation (Q2 2026 deadline). Use for any `nf-core pipelines` operation.
argument-hint: "[create|lint|schema|sync|release] [args]"
disable-model-invocation: true
allowed-tools:
  - Bash(conda run *)
  - Bash(nf-core *)
  - Bash(nf-test *)
  - Bash(nextflow *)
  - Bash(uv run *)
  - Bash(git *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# nf-core Pipelines

Full pipeline lifecycle: create, lint, schema, sync, and release.

Read `${CLAUDE_PLUGIN_ROOT}/shared/conventions.md` for nf-core conventions and package manager setup.

---

## nf-core Migration Roadmap

> Update this table as Nextflow and nf-core evolve. Last updated: Feb 2026.

| Feature | Enforce? | Allow in Linting | In Template | Required | Notes |
|---------|----------|-----------------|-------------|----------|-------|
| Strict syntax | **ENFORCE** | — | Q2 2026 | Q2 2026 | CRITICAL deadline. Run `nextflow lint .` |
| Version topics in modules | **ENFORCE** | Q4 2025 | Mid-2026 | Mid-2026 | Already allowed by linting |
| Workflow output | Don't enforce | — | Mid-2026 | Q4 2026 | Coming soon |
| Static types & records | Don't enforce | Mid-2026 | Q4 2026 | Q2 2027 | Gradual rollout |
| New process syntax | Don't enforce | Mid-2026 | Q4 2026 | Q2 2027 | Gradual rollout |

---

## Quick Commands

Replace `<cmd>` with the configured package manager prefix (see Setup in conventions.md).

| Action | Command |
|--------|---------|
| Create pipeline | `<cmd> nf-core pipelines create` |
| Strict syntax lint | `<cmd> nextflow lint .` |
| Community lint | `<cmd> nf-core pipelines lint` |
| Lint with auto-fix | `<cmd> nf-core pipelines lint --fix` |
| Build schema | `<cmd> nf-core pipelines schema build` |
| Lint schema | `<cmd> nf-core pipelines schema lint` |
| Validate params | `<cmd> nf-core pipelines schema validate <pipeline> params.json` |
| Check sync status | `<cmd> nf-core pipelines sync --show` |
| Run sync | `<cmd> nf-core pipelines sync` |
| Run tests | `<cmd> nf-test test` |

---

## Create Pipeline

### Naming Rules

- **Lowercase only**: `rnaseq` not `RNAseq`
- **No punctuation**: `methylseq` not `methyl-seq`
- **Descriptive**: Name should indicate data type or analysis
- **Unique**: Check existing pipelines at https://nf-co.re/pipelines

### Commands

```bash
# Interactive (recommended)
<cmd> nf-core pipelines create

# Non-interactive
<cmd> nf-core pipelines create --name mypipeline --description "Description" --author "Name"

# From template YAML
<cmd> nf-core pipelines create --template-yaml template.yml

# Custom organization
<cmd> nf-core pipelines create --org myorg
```

### Template Features

| Feature | Description | Default |
|---------|-------------|---------|
| `github` | GitHub integration, CI | Yes |
| `ci` | Continuous integration | Yes |
| `igenomes` | iGenomes reference config | Yes |
| `multiqc` | MultiQC report | Yes |
| `fastqc` | FastQC quality control | Yes |
| `nf_schema` | Parameter validation | Yes |
| `codespaces` | GitHub Codespaces | No |
| `slackreport` | Slack notifications | No |

### Generated Structure

```
nf-core-mypipeline/
├── .github/              # GitHub Actions, templates
├── assets/               # Email templates, logos
├── bin/                  # Custom scripts
├── conf/                 # base.config, modules.config, test.config
├── docs/                 # usage.md, output.md
├── lib/                  # Groovy libraries
├── modules/              # local/ and nf-core/
├── subworkflows/         # local/ and nf-core/
├── workflows/            # Main workflow
├── main.nf               # Entry point
├── nextflow.config       # Main config
├── nextflow_schema.json  # Parameter schema
└── CHANGELOG.md
```

### Git Branches

- `master`/`main`: Stable releases only
- `dev`: Active development
- `TEMPLATE`: Vanilla template for sync

---

## Lint Pipeline

### Nextflow Strict Syntax (CRITICAL — Q2 2026 Deadline)

**Always run strict syntax lint first.** All nf-core pipelines must pass by Q2 2026.

```bash
<cmd> nextflow lint .
<cmd> nextflow lint main.nf workflows/ modules/
```

What it checks:
- **Errors**: for/while loops, switch, imports, top-level classes, unquoted env, addParams
- **Warnings**: `Channel.` uppercase, implicit closure params, `shell:` blocks

### nf-core Community Lint

```bash
<cmd> nf-core pipelines lint
<cmd> nf-core pipelines lint --fix          # Auto-fix (requires clean git)
<cmd> nf-core pipelines lint --dir /path    # Specific directory
<cmd> nf-core pipelines lint -k files_exist # Specific tests only
```

### Complete Linting Workflow

1. Run `nextflow lint .` — fix all errors, then warnings
2. Run `nf-core pipelines lint` — fix FAILED, then WARNED
3. Run `nf-core pipelines lint --fix` — apply auto-fixes
4. Verify both pass with zero errors

### Common Lint Categories

| Category | Description |
|----------|-------------|
| `files_exist` | Required files (LICENSE, CITATIONS.md, etc.) |
| `files_unchanged` | Template files not to modify |
| `nextflow_config` | Config validation (manifest, params, profiles) |
| `schema_lint` | nextflow_schema.json structure |
| `pipeline_todos` | TODO comments to address |
| `version_consistency` | Version numbers match across files |

### Configuring .nf-core.yml Exceptions

```yaml
lint:
  pipeline_todos: false         # Disable test
  files_exist:
    - CODE_OF_CONDUCT.md        # Skip specific file
  files_unchanged:
    - .github/CONTRIBUTING.md
```

### Common Lint Fixes

**Missing files** (`files_exist`): Create LICENSE, CODE_OF_CONDUCT.md, CITATIONS.md.

**Schema issues** (`schema_lint`): Run `<cmd> nf-core pipelines schema build`.

**Config issues** (`nextflow_config`): Ensure complete manifest with `name`, `version`, `nextflowVersion`, etc.

**TODOs** (`pipeline_todos`): Remove or implement TODO comments.

---

## Schema Management

### Build/Update Schema

```bash
<cmd> nf-core pipelines schema build          # Generate from nextflow.config
<cmd> nf-core pipelines schema build --web-only  # Web interface only
```

### Adding a Parameter

1. Add param to `nextflow.config` `params { }` block
2. Run `<cmd> nf-core pipelines schema build`
3. Set type, description, constraints in prompts or web UI

### Parameter Types

| Type | Example | Use Case |
|------|---------|----------|
| `string` | `"value"` | Text, paths, enums |
| `integer` | `10` | Whole numbers |
| `number` | `0.05` | Decimals |
| `boolean` | `true/false` | Flags |

### Standard Parameter Groups

1. **Input/output options**: `--input`, `--outdir`
2. **Reference genome options**: `--genome`, `--fasta`
3. **Process skipping options**: `--skip_*` flags
4. **Max job request options**: `--max_cpus`, `--max_memory`, `--max_time`

### Samplesheet Schema

Define samplesheet columns in `assets/schema_input.json`:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "array",
  "items": {
    "type": "object",
    "required": ["sample", "fastq_1"],
    "properties": {
      "sample": { "type": "string", "pattern": "^\\S+$" },
      "fastq_1": { "type": "string", "format": "file-path", "exists": true },
      "fastq_2": { "type": "string", "format": "file-path", "exists": true }
    }
  }
}
```

Reference from `nextflow_schema.json`:
```json
"input": {
  "type": "string",
  "format": "file-path",
  "schema": "assets/schema_input.json"
}
```

### Generate Samplesheet from FASTQs

```bash
echo "sample,fastq_1,fastq_2,strandedness" > samplesheet.csv
for f in *_R1.fastq.gz; do
    sample=$(basename "$f" _R1.fastq.gz)
    echo "${sample},$(pwd)/${f},$(pwd)/${sample}_R2.fastq.gz,auto"
done >> samplesheet.csv
```

---

## Template Sync

### How It Works

1. **TEMPLATE branch** contains vanilla nf-core template with your pipeline metadata
2. **Sync** updates TEMPLATE with latest template version
3. **PR** opens from TEMPLATE to dev
4. **Merge** after reviewing and resolving conflicts

```
master ────────────────────► (releases only)
dev ────●─────●─────●──────► (active development)
        │     ▲
        │     │ merge sync PR
TEMPLATE ●────●─────────────► (template updates)
```

### Commands

```bash
<cmd> nf-core pipelines sync                    # Run sync (creates PR)
<cmd> nf-core pipelines sync --no-pull-request  # No PR
<cmd> nf-core pipelines sync --make-template-branch  # Recreate TEMPLATE
```

### Resolving Merge Conflicts

- **nextflow.config**: Keep custom params, take structural changes
- **CI workflows**: Take template version, add back custom jobs
- **README.md**: Merge carefully, keep custom content

### Fixing Broken TEMPLATE Branch

```bash
git branch -D TEMPLATE
git fetch origin TEMPLATE:TEMPLATE
# Or recreate:
<cmd> nf-core pipelines sync --make-template-branch
```

---

## Release Preparation

### Release Checklist

1. **Version**: Update `manifest.version` in `nextflow.config` (semver: MAJOR.MINOR.PATCH)
2. **CHANGELOG.md**: Add version section with date, categorize (Added/Changed/Fixed)
3. **Documentation**: `docs/usage.md`, `docs/output.md`, `README.md` up to date
4. **Schema**: `nextflow_schema.json` matches all params (`<cmd> nf-core pipelines schema build`)
5. **Lint**: `nextflow lint .` zero errors, `nf-core pipelines lint` all pass
6. **Tests**: `<cmd> nf-test test` all pass, CI green
7. **Modules**: All updated to latest versions
8. **Containers**: Versioned (no `:latest`), Docker and Singularity work
9. **Citations**: `CITATIONS.md` lists all tools with DOIs

### Version Numbering

| Change Type | Bump | Example |
|-------------|------|---------|
| Breaking changes | MAJOR | 1.0.0 → 2.0.0 |
| New features | MINOR | 1.0.0 → 1.1.0 |
| Bug fixes | PATCH | 1.0.0 → 1.0.1 |

### Release Process

```bash
# 1. Ensure dev is up to date
git checkout dev && git pull origin dev

# 2. Run full validation
<cmd> nextflow lint .
<cmd> nf-core pipelines lint
<cmd> nf-test test

# 3. Update version in nextflow.config and CHANGELOG.md
# 4. Commit and push
git commit -m "Prepare release X.Y.Z"
git push origin dev

# 5. Create release PR (dev → master)
gh pr create --base master --head dev --title "Release X.Y.Z"

# 6. After merge, tag release
git checkout master && git pull
git tag -a X.Y.Z -m "Release X.Y.Z"
git push origin X.Y.Z
```
