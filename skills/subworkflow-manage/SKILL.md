---
name: subworkflow-manage
description: Manage nf-core subworkflows - install, create, update, lint, and test. Use when working with subworkflows, composing pipelines from reusable workflow components, or creating new subworkflows.
argument-hint: "[list|install|create|update|lint|test] [name]"
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# nf-core Subworkflow Management

Manage subworkflows - reusable workflow components that combine multiple modules.

## Quick Commands

```bash
# List available subworkflows
conda run -n nf-core nf-core subworkflows list remote

# List installed subworkflows
conda run -n nf-core nf-core subworkflows list local

# Get subworkflow info
conda run -n nf-core nf-core subworkflows info bam_sort_stats_samtools

# Install subworkflow
conda run -n nf-core nf-core subworkflows install bam_sort_stats_samtools

# Create new subworkflow
conda run -n nf-core nf-core subworkflows create

# Update subworkflow
conda run -n nf-core nf-core subworkflows update bam_sort_stats_samtools

# Update all subworkflows
conda run -n nf-core nf-core subworkflows update --all

# Lint subworkflow
conda run -n nf-core nf-core subworkflows lint bam_sort_stats_samtools

# Test subworkflow
conda run -n nf-core nf-test test subworkflows/nf-core/bam_sort_stats_samtools/
```

## What are Subworkflows?

Subworkflows combine multiple modules into reusable workflow units:

```
Subworkflow: BAM_SORT_STATS_SAMTOOLS
├── SAMTOOLS_SORT
├── SAMTOOLS_INDEX
└── SAMTOOLS_STATS
```

Benefits:
- Reduce code duplication
- Consistent implementation across pipelines
- Easier maintenance
- Modular pipeline design

## Installing Subworkflows

```bash
# Install from nf-core/modules repo
conda run -n nf-core nf-core subworkflows install bam_sort_stats_samtools

# Install specific version
conda run -n nf-core nf-core subworkflows install bam_sort_stats_samtools --sha abc123

# Force reinstall
conda run -n nf-core nf-core subworkflows install bam_sort_stats_samtools --force
```

Installation creates:
```
subworkflows/nf-core/bam_sort_stats_samtools/
├── main.nf
├── meta.yml
└── tests/
    ├── main.nf.test
    └── main.nf.test.snap
```

## Using Subworkflows

```nextflow
// Include in your workflow
include { BAM_SORT_STATS_SAMTOOLS } from '../subworkflows/nf-core/bam_sort_stats_samtools/main'

workflow MY_PIPELINE {
    take:
    bam  // channel: [ val(meta), path(bam) ]
    fasta
    fai

    main:
    BAM_SORT_STATS_SAMTOOLS ( bam, fasta, fai )

    emit:
    bam   = BAM_SORT_STATS_SAMTOOLS.out.bam
    bai   = BAM_SORT_STATS_SAMTOOLS.out.bai
    stats = BAM_SORT_STATS_SAMTOOLS.out.stats
}
```

## Creating Subworkflows

### Interactive Creation
```bash
conda run -n nf-core nf-core subworkflows create
```

### Subworkflow Structure

**main.nf**:
```nextflow
include { MODULE_ONE } from '../../../modules/nf-core/module_one/main'
include { MODULE_TWO } from '../../../modules/nf-core/module_two/main'

workflow MY_SUBWORKFLOW {
    take:
    input_channel  // channel: [ val(meta), path(input) ]
    reference      // channel: path(reference)

    main:
    ch_versions = channel.empty()

    MODULE_ONE ( input_channel )
    ch_versions = ch_versions.mix(MODULE_ONE.out.versions.first())

    MODULE_TWO ( MODULE_ONE.out.result, reference )
    ch_versions = ch_versions.mix(MODULE_TWO.out.versions.first())

    emit:
    result   = MODULE_TWO.out.output  // channel: [ val(meta), path(output) ]
    versions = ch_versions            // channel: path(versions.yml)
}
```

**meta.yml**:
```yaml
name: my_subworkflow
description: Brief description
keywords:
  - keyword1
  - keyword2
components:
  - module_one
  - module_two
input:
  - - meta:
        type: map
        description: Sample metadata
    - input:
        type: file
        description: Input file
        pattern: "*.{bam,sam}"
  - - reference:
        type: file
        description: Reference file
output:
  - result:
      - meta:
          type: map
      - "*.out":
          type: file
          description: Output file
  - versions:
      - versions.yml:
          type: file
authors:
  - "@username"
maintainers:
  - "@username"
```

## Popular Subworkflows

| Subworkflow | Description |
|-------------|-------------|
| `bam_sort_stats_samtools` | Sort BAM, index, generate stats |
| `bam_markduplicates_picard` | Mark duplicates with Picard |
| `bam_stats_samtools` | Generate BAM statistics |
| `fastq_trim_fastp_fastqc` | Trim reads and QC |
| `vcf_annotate_ensemblvep` | Annotate VCF with VEP |

## Local vs Remote Subworkflows

### Remote (nf-core)
```
subworkflows/nf-core/   # Installed from nf-core/modules
```

### Local (pipeline-specific)
```
subworkflows/local/     # Custom subworkflows
```

Create local subworkflow:
```bash
mkdir -p subworkflows/local/my_subworkflow
# Create main.nf and meta.yml manually
```

## Updating Subworkflows

```bash
# Preview updates
conda run -n nf-core nf-core subworkflows update --preview

# Update specific subworkflow
conda run -n nf-core nf-core subworkflows update bam_sort_stats_samtools

# Update all
conda run -n nf-core nf-core subworkflows update --all
```

## Linting Subworkflows

```bash
# Lint specific subworkflow
conda run -n nf-core nf-core subworkflows lint my_subworkflow

# Lint all subworkflows
conda run -n nf-core nf-core subworkflows lint --all
```

## Testing Subworkflows

```bash
# Run tests
conda run -n nf-core nf-test test subworkflows/nf-core/bam_sort_stats_samtools/

# Update snapshots
conda run -n nf-core nf-test test subworkflows/nf-core/bam_sort_stats_samtools/ --update-snapshot
```

## Best Practices

1. **Use existing subworkflows**: Check nf-core/modules before creating custom
2. **Minimal I/O**: Keep inputs/outputs focused
3. **Version tracking**: Include versions.yml collection
4. **Comprehensive tests**: Test all input combinations
5. **Document thoroughly**: Complete meta.yml descriptions
6. **Consistent naming**: Follow nf-core naming conventions
