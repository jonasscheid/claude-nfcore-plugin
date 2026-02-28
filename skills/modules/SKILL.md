---
name: modules
description: Manage nf-core modules and subworkflows — create, install, update, patch, and lint. Use for any `nf-core modules` or `nf-core subworkflows` operation.
argument-hint: "[create|install|update|patch|lint] [name]"
disable-model-invocation: true
allowed-tools:
  - Bash(conda run *)
  - Bash(nf-core *)
  - Bash(nf-test *)
  - Bash(nextflow *)
  - Bash(uv run *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - WebFetch(bioconda.github.io/*, quay.io/*)
---

# nf-core Modules & Subworkflows

Manage modules and subworkflows: create, install, update, patch, and lint.

Read `${CLAUDE_PLUGIN_ROOT}/shared/conventions.md` for nf-core conventions and package manager setup.
Read `${CLAUDE_PLUGIN_ROOT}/shared/module-template.md` for module structure and templates.

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

## Quick Commands — Modules

Replace `<cmd>` with the configured package manager prefix (see Setup in conventions.md).

| Action | Command |
|--------|---------|
| List remote modules | `<cmd> nf-core modules list remote` |
| List installed modules | `<cmd> nf-core modules list local` |
| Module info | `<cmd> nf-core modules info <module>` |
| Install module | `<cmd> nf-core modules install <tool/subtool>` |
| Install specific version | `<cmd> nf-core modules install <module> --sha <commit>` |
| Create module | `<cmd> nf-core modules create tool/subtool` |
| Update module | `<cmd> nf-core modules update <module>` |
| Update all | `<cmd> nf-core modules update --all` |
| Preview updates | `<cmd> nf-core modules update --preview` |
| Create patch | `<cmd> nf-core modules patch <module>` |
| Remove patch | `<cmd> nf-core modules patch <module> --remove` |
| Lint module | `<cmd> nf-core modules lint <module>` |
| Lint all | `<cmd> nf-core modules lint --all` |
| Test module | `<cmd> nf-test test modules/nf-core/<tool>/<subtool>/` |

## Quick Commands — Subworkflows

| Action | Command |
|--------|---------|
| List remote | `<cmd> nf-core subworkflows list remote` |
| List installed | `<cmd> nf-core subworkflows list local` |
| Install | `<cmd> nf-core subworkflows install <name>` |
| Create | `<cmd> nf-core subworkflows create` |
| Update | `<cmd> nf-core subworkflows update <name>` |
| Update all | `<cmd> nf-core subworkflows update --all` |
| Lint | `<cmd> nf-core subworkflows lint <name>` |
| Test | `<cmd> nf-test test subworkflows/nf-core/<name>/` |

---

## Module Lifecycle

### Create

Module naming: `tool` or `tool/subtool`, lowercase only. Examples: `fastqc`, `bwa/mem`, `samtools/sort`.

```bash
<cmd> nf-core modules create tool/subtool
```

See `${CLAUDE_PLUGIN_ROOT}/shared/module-template.md` for the complete main.nf template, meta.yml structure, and container sources.

Process:
1. Check Bioconda for tool availability
2. Run create command to generate scaffold
3. Edit main.nf — implement process logic
4. Update meta.yml — document inputs, outputs
5. Write nf-test tests
6. Lint: `<cmd> nf-core modules lint tool/subtool`

### Install

```bash
<cmd> nf-core modules install <tool/subtool>
```

Installs to `modules/nf-core/<tool>/<subtool>/`.

**Integration example:**
```nextflow
include { FASTQC } from '../modules/nf-core/fastqc/main'

workflow MY_WORKFLOW {
    take:
    reads  // channel: [ val(meta), path(reads) ]

    main:
    FASTQC ( reads )

    emit:
    zip  = FASTQC.out.zip
    html = FASTQC.out.html
}
```

**Configure ext.args:**
```nextflow
// conf/modules.config
process {
    withName: FASTQC {
        ext.args = '--quiet'
        publishDir = [
            path: { "${params.outdir}/fastqc" },
            mode: params.publish_dir_mode,
            saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
}
```

### Update

```bash
<cmd> nf-core modules update <module>          # Update one
<cmd> nf-core modules update --all             # Update all
<cmd> nf-core modules update --preview         # Preview only
<cmd> nf-core modules update <module> --force  # Overwrite local changes
<cmd> nf-core modules update <module> --save-diff updates.patch  # Save as patch
```

Modules are tracked in `modules.json` with git SHA and branch info.

**Workflow**: Preview → Update → Test → Commit
```bash
<cmd> nf-core modules update <module> --preview
<cmd> nf-core modules update <module>
<cmd> nf-test test modules/nf-core/<module>/
git add modules/nf-core/<module>/ modules.json && git commit -m "Update <module>"
```

### Patch

Use patches to preserve local modifications across module updates.

**When to patch vs. local module:**
- **Patch**: Small, focused changes (custom args, label change, conditional logic)
- **Local module**: Extensive changes (>50% of code), very different usage

```bash
# 1. Install and modify module
<cmd> nf-core modules install fastqc
# Edit modules/nf-core/fastqc/main.nf

# 2. Create patch
<cmd> nf-core modules patch fastqc
# Creates modules/nf-core/fastqc/.nf-core-patch.yaml

# 3. On update, patch auto-applies
<cmd> nf-core modules update fastqc
```

**Remove patch:**
```bash
<cmd> nf-core modules patch fastqc --remove
```

---

## Subworkflow Lifecycle

Subworkflows combine multiple modules into reusable workflow units.

### Install

```bash
<cmd> nf-core subworkflows install bam_sort_stats_samtools
```

Installs to `subworkflows/nf-core/<name>/` with main.nf, meta.yml, and tests/.

**Usage:**
```nextflow
include { BAM_SORT_STATS_SAMTOOLS } from '../subworkflows/nf-core/bam_sort_stats_samtools/main'

workflow {
    BAM_SORT_STATS_SAMTOOLS ( bam_ch, fasta, fai )
}
```

### Create

```bash
<cmd> nf-core subworkflows create
```

**Subworkflow main.nf structure:**
```nextflow
include { MODULE_ONE } from '../../../modules/nf-core/module_one/main'
include { MODULE_TWO } from '../../../modules/nf-core/module_two/main'

workflow MY_SUBWORKFLOW {
    take:
    input_channel
    reference

    main:
    ch_versions = channel.empty()

    MODULE_ONE ( input_channel )
    ch_versions = ch_versions.mix(MODULE_ONE.out.versions.first())

    MODULE_TWO ( MODULE_ONE.out.result, reference )
    ch_versions = ch_versions.mix(MODULE_TWO.out.versions.first())

    emit:
    result   = MODULE_TWO.out.output
    versions = ch_versions
}
```

### Update

```bash
<cmd> nf-core subworkflows update <name>
<cmd> nf-core subworkflows update --all
<cmd> nf-core subworkflows update --preview
```

### Local vs Remote

- **Remote** (`subworkflows/nf-core/`): Installed from nf-core/modules, managed by nf-core tools
- **Local** (`subworkflows/local/`): Pipeline-specific, manually maintained

---

## Lint Modules & Subworkflows

### Running Lint

```bash
<cmd> nf-core modules lint <module>        # Lint specific module
<cmd> nf-core modules lint --all           # Lint all modules
<cmd> nf-core subworkflows lint <name>     # Lint specific subworkflow
<cmd> nf-core subworkflows lint --all      # Lint all subworkflows
```

### Common Module Lint Fixes

- **Missing meta.yml fields**: Add description, keywords, authors
- **Missing stub block**: Add stub section to process
- **Missing versions.yml**: Add version reporting output
- **Container issues**: Pin versions (no `:latest`), ensure both Docker and Singularity
- **Output patterns**: Use `path("${prefix}.ext")` not `path("*.ext")`

### Configuring .nf-core.yml for Module Exceptions

```yaml
lint:
  modules:
    - name: custom_module
      tests:
        - meta_yml
```

---

## Module Structure Reference

See `${CLAUDE_PLUGIN_ROOT}/shared/module-template.md` for complete templates including:
- Standard main.nf process template (input/output/script/stub)
- meta.yml structure
- Container sources (biocontainers, quay.io)
- Module file structure diagram
