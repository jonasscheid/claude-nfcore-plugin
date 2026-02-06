---
name: best-practices
description: Comprehensive reference guide for nf-core standards, Nextflow DSL2 patterns, and best practices. Use when asking about conventions, coding style, proper patterns, common fixes, or how to structure nf-core pipelines and modules correctly.
user-invocable: true
---

# nf-core Best Practices Reference

Comprehensive guide to nf-core standards, Nextflow conventions, and best practices.

---

## Table of Contents
1. [Nextflow DSL2 Conventions](#nextflow-dsl2-conventions)
2. [Parameter Naming](#parameter-naming)
3. [Channel Naming](#channel-naming)
4. [Process Structure](#process-structure)
5. [Module Guidelines](#module-guidelines)
6. [Configuration Patterns](#configuration-patterns)
7. [Testing Standards](#testing-standards)
8. [Documentation Requirements](#documentation-requirements)
9. [Git Workflow](#git-workflow)
10. [Common Lint Fixes](#common-lint-fixes)

---

## Nextflow DSL2 Conventions

### Use Lowercase `channel.`

**IMPORTANT**: Always use lowercase `channel.` factory methods, not `Channel.`

```nextflow
// CORRECT
ch_input = channel.fromPath(params.input)
ch_empty = channel.empty()
ch_value = channel.value('test')
ch_files = channel.fromFilePairs(params.reads)

// INCORRECT - DO NOT USE
ch_input = Channel.fromPath(params.input)
ch_empty = Channel.empty()
```

### Channel Factory Methods

```nextflow
// From file path
channel.fromPath('/path/to/*.fastq.gz')
channel.fromPath(params.input, checkIfExists: true)

// From file pairs (paired-end reads)
channel.fromFilePairs('/path/to/*_{1,2}.fastq.gz')

// From SRA accessions
channel.fromSRA('SRR1234567')

// Empty channel
channel.empty()

// Single value channel
channel.value('constant')
channel.of('item1', 'item2', 'item3')
```

### Channel Operations

```nextflow
// Map - transform elements
ch_input
    .map { meta, reads -> [ meta, reads, meta.single_end ] }

// Filter - select elements
ch_input
    .filter { meta, reads -> !meta.single_end }

// Branch - split by condition
ch_input
    .branch {
        single: it[0].single_end
        paired: !it[0].single_end
    }

// Combine channels
ch_a.mix(ch_b)           // Merge channels
ch_a.join(ch_b)          // Join by key
ch_a.combine(ch_b)       // Cartesian product
ch_a.concat(ch_b)        // Concatenate in order

// Collect versions
ch_versions = ch_versions.mix(PROCESS.out.versions.first())
```

---

## Parameter Naming

### Use snake_case

```nextflow
// CORRECT
params.input_file
params.min_read_length
params.output_dir
params.skip_quality_control

// INCORRECT
params.inputFile      // camelCase
params.min-read-len   // kebab-case
params.MinReadLength  // PascalCase
```

### Boolean Parameters: Use Negative Form

```nextflow
// CORRECT - negative form (skip/disable)
params.skip_fastqc = false
params.skip_trimming = false
params.skip_alignment = false
params.disable_validation = false

// INCORRECT - positive form
params.run_fastqc = true       // Should be skip_fastqc
params.enable_trimming = true  // Should be skip_trimming
```

This allows simpler command line usage:
```bash
# User only specifies flags to SKIP steps
nextflow run pipeline --skip_fastqc --skip_trimming

# Not having to specify what to run
# nextflow run pipeline --run_fastqc --run_trimming  # AVOID
```

### Standard Parameter Names

| Parameter | Description |
|-----------|-------------|
| `input` | Primary input samplesheet |
| `outdir` | Output directory |
| `fasta` | Reference FASTA file |
| `gtf` | GTF annotation file |
| `genome` | iGenomes genome key |
| `email` | Email for notifications |
| `publish_dir_mode` | Publish directory mode |
| `max_cpus` | Maximum CPUs per process |
| `max_memory` | Maximum memory per process |
| `max_time` | Maximum time per process |

---

## Channel Naming

### Prefix with `ch_`

```nextflow
// CORRECT
ch_input
ch_reads
ch_fasta
ch_versions
ch_multiqc_files

// INCORRECT
input_ch        // suffix not prefix
reads           // no prefix
INPUT_CHANNEL   // uppercase
```

### Descriptive Names

```nextflow
// CORRECT - descriptive
ch_filtered_reads
ch_sorted_bam
ch_called_variants
ch_multiqc_custom_config

// INCORRECT - vague
ch_data
ch_output
ch_files
```

---

## Process Structure

### Standard Process Template

```nextflow
process TOOL_SUBTOOL {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tool:1.0--h123' :
        'quay.io/biocontainers/tool:1.0--h123' }"

    input:
    tuple val(meta), path(input_file)
    path reference

    output:
    tuple val(meta), path("${prefix}.out"), emit: result
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    tool subtool \\
        $args \\
        --threads $task.cpus \\
        --reference $reference \\
        --input $input_file \\
        --output ${prefix}.out

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tool: \$(tool --version 2>&1 | sed 's/.*version //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.out

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tool: 1.0.0
    END_VERSIONS
    """
}
```

### Process Labels

| Label | CPUs | Memory | Time |
|-------|------|--------|------|
| `process_single` | 1 | 6.GB | 4.h |
| `process_low` | 2 | 12.GB | 4.h |
| `process_medium` | 6 | 36.GB | 8.h |
| `process_high` | 12 | 72.GB | 16.h |
| `process_long` | 2 | 12.GB | 20.h |
| `process_high_memory` | 10 | 200.GB | 12.h |

### The meta Map

Standard meta map structure:
```groovy
meta = [
    id: 'sample_name',      // Required: unique identifier
    single_end: false,      // Boolean for SE/PE
    strandedness: 'auto',   // Optional: strand info
    // Add pipeline-specific fields as needed
]
```

---

## Output Glob Patterns

### Use Prefix-Based Output Patterns

**IMPORTANT**: Always use prefix-based output glob patterns (e.g., `path("${prefix}.bam")`) instead of broad wildcard patterns (e.g., `path("*.bam")`).

Broad wildcard patterns like `path("*.bam")` will match **both** output files and any input files with the same extension that were staged into the task working directory. This causes input files to be unnecessarily captured as outputs and copied back, which:

- **Increases cloud storage costs** (e.g., AWS S3 copy overhead)
- **Slows down execution** due to redundant file transfers
- **May cause incorrect results** if downstream processes receive unexpected files

```nextflow
// CORRECT - only captures files generated by this process
output:
tuple val(meta), path("${prefix}.vcf.gz")      , emit: vcf
tuple val(meta), path("${prefix}.vcf.gz.tbi")   , emit: tbi
tuple val(meta), path("${prefix}.bam")           , emit: bam

// INCORRECT - captures ALL matching files including staged inputs
output:
tuple val(meta), path("*.vcf.gz")    , emit: vcf    // May capture input VCFs!
tuple val(meta), path("*.vcf.gz.tbi"), emit: tbi
tuple val(meta), path("*.bam")       , emit: bam    // May capture input BAMs!
```

This is particularly important for processes that receive extra files as inputs (e.g., VEP cache files, reference panels, annotation databases) where the input files share the same extension as the output.

**Rule of thumb**: If the tool writes output to `${prefix}.ext`, the output declaration should be `path("${prefix}.ext")`, not `path("*.ext")`.

---

## Module Guidelines

### File Structure

```
modules/nf-core/tool/subtool/
├── main.nf              # Process definition
├── meta.yml             # Metadata
├── environment.yml      # Conda environment
└── tests/
    ├── main.nf.test     # nf-test tests
    ├── main.nf.test.snap # Snapshots
    ├── nextflow.config  # Test config
    └── tags.yml         # Tags
```

### Use `ext.args` for Tool Arguments

```nextflow
// In modules.config
process {
    withName: 'FASTQC' {
        ext.args = '--quiet --noextract'
    }
    withName: 'BWA_MEM' {
        ext.args = '-M -K 100000000'
    }
}

// In process
script:
def args = task.ext.args ?: ''
"""
fastqc $args $reads
"""
```

### Output Declarations

Always use prefix-based output patterns, not broad wildcards:

```nextflow
// CORRECT
output:
tuple val(meta), path("${prefix}.bam"), emit: bam

// INCORRECT - may capture staged input files
output:
tuple val(meta), path("*.bam"), emit: bam
```

### Version Reporting

Always emit versions:
```nextflow
output:
path "versions.yml", emit: versions

script:
"""
cat <<-END_VERSIONS > versions.yml
"${task.process}":
    tool: \$(tool --version | head -1)
END_VERSIONS
"""
```

---

## Configuration Patterns

### Config File Hierarchy

```
nextflow.config          # Main config
├── conf/base.config     # Resource defaults
├── conf/modules.config  # Module-specific config
├── conf/test.config     # Test profile
└── conf/test_full.config # Full test profile
```

### Profile Structure

```nextflow
profiles {
    debug {
        dumpHashes             = true
        process.beforeScript   = 'echo $HOSTNAME'
        cleanup                = false
        nextflow.enable.configProcessNamesValidation = true
    }
    docker {
        docker.enabled         = true
        conda.enabled          = false
        singularity.enabled    = false
        docker.runOptions      = '-u $(id -u):$(id -g)'
    }
    singularity {
        singularity.enabled    = true
        singularity.autoMounts = true
        conda.enabled          = false
        docker.enabled         = false
    }
    test {
        includeConfig 'conf/test.config'
    }
}
```

### Resource Configuration

```nextflow
// conf/base.config
process {
    cpus   = { check_max( 1    * task.attempt, 'cpus'   ) }
    memory = { check_max( 6.GB * task.attempt, 'memory' ) }
    time   = { check_max( 4.h  * task.attempt, 'time'   ) }

    errorStrategy = { task.exitStatus in ((130..145) + 104) ? 'retry' : 'finish' }
    maxRetries    = 1
    maxErrors     = '-1'

    withLabel:process_single {
        cpus   = { check_max( 1                  , 'cpus'   ) }
        memory = { check_max( 6.GB * task.attempt, 'memory' ) }
        time   = { check_max( 4.h  * task.attempt, 'time'   ) }
    }
    withLabel:process_medium {
        cpus   = { check_max( 6     * task.attempt, 'cpus'   ) }
        memory = { check_max( 36.GB * task.attempt, 'memory' ) }
        time   = { check_max( 8.h   * task.attempt, 'time'   ) }
    }
}
```

---

## Testing Standards

### nf-test Structure

```groovy
nextflow_process {
    name "Test Process TOOL"
    script "../main.nf"
    process "TOOL"

    tag "modules"
    tag "tool"

    test("Should run with SE reads") {
        when {
            process {
                """
                input[0] = [
                    [ id:'test', single_end:true ],
                    file(params.test_data['species']['type']['file'], checkIfExists: true)
                ]
                """
            }
        }

        then {
            assert process.success
            assert snapshot(process.out).match()
        }
    }
}
```

### Test Coverage

- Test all input combinations (SE/PE, optional inputs)
- Test edge cases
- Include stub tests for large data tools
- Snapshot all outputs

---

## Documentation Requirements

### README.md

Must include:
- Pipeline description
- Quick start guide
- Input requirements
- Output description
- Credits section

### docs/usage.md

- Detailed usage instructions
- Samplesheet format
- All parameters explained
- Example commands

### docs/output.md

- All output files documented
- Directory structure explained
- File format descriptions

---

## Git Workflow

### Branch Structure

- `master` / `main`: Stable releases only
- `dev`: Active development
- `TEMPLATE`: Template sync branch

### PR Guidelines

- PRs target `dev` branch (not master)
- Require at least one approval
- All CI tests must pass
- Lint must pass

### Commit Messages

- Clear, descriptive messages
- Reference issues: "Fix alignment bug (#123)"
- Use conventional commits when possible

---

## Common Lint Fixes

### "files_exist" Failures

Create missing required files:
- `LICENSE` - MIT license
- `CODE_OF_CONDUCT.md` - Community guidelines
- `CITATIONS.md` - Tool citations

### "nextflow_config" Issues

```nextflow
// Ensure manifest is complete
manifest {
    name            = 'nf-core/mypipeline'
    author          = 'Author Name'
    homePage        = 'https://github.com/nf-core/mypipeline'
    description     = 'Pipeline description'
    mainScript      = 'main.nf'
    nextflowVersion = '!>=23.04.0'
    version         = '1.0.0'
    doi             = ''
}
```

### "schema_lint" Fixes

```bash
# Rebuild schema
conda run -n nf-core nf-core pipelines schema build
```

### "pipeline_todos" Warnings

Remove or complete TODO comments:
```nextflow
// TODO: Implement feature  // REMOVE or implement
```

### "files_unchanged" Issues

Don't modify template files excessively. If needed, configure in `.nf-core.yml`:
```yaml
lint:
  files_unchanged:
    - .github/CONTRIBUTING.md
```

---

## Quick Reference

### Commands Cheat Sheet

```bash
# Pipeline commands
conda run -n nf-core nf-core pipelines create
conda run -n nf-core nf-core pipelines lint [--fix]
conda run -n nf-core nf-core pipelines schema build
conda run -n nf-core nf-core pipelines sync

# Module commands
conda run -n nf-core nf-core modules list remote
conda run -n nf-core nf-core modules install <name>
conda run -n nf-core nf-core modules update [--all]
conda run -n nf-core nf-core modules patch <name>
conda run -n nf-core nf-core modules create

# Testing
conda run -n nf-core nf-test test [path]
conda run -n nf-core nf-test test --update-snapshot
```

### Key Conventions Summary

| Aspect | Convention |
|--------|------------|
| Channel factory | `channel.` (lowercase) |
| Parameters | `snake_case` |
| Booleans | Negative form (`skip_X`) |
| Channel names | `ch_` prefix |
| Process names | `UPPERCASE` |
| Output patterns | `path("${prefix}.ext")` (not `path("*.ext")`) |
| Git target | `dev` branch |
| Package manager | Prefer `mamba` |
