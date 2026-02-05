---
name: module-create
description: Create a new nf-core module from scratch. Use when creating custom modules, wrapping new bioinformatics tools, or contributing modules to nf-core/modules repository.
argument-hint: "[tool/subtool]"
disable-model-invocation: true
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - WebFetch(bioconda.github.io/*, quay.io/*)
---

# Create nf-core Module

Generate a new Nextflow module following nf-core standards for tool wrapping.

## Quick Commands

```bash
# Interactive module creation
conda run -n nf-core nf-core modules create

# Create with tool name specified
conda run -n nf-core nf-core modules create tool/subtool

# Create local module (pipeline-specific)
conda run -n nf-core nf-core modules create --local tool/subtool

# Create in specific directory
conda run -n nf-core nf-core modules create --dir /path/to/pipeline tool/subtool
```

## Process

1. **Check Bioconda**: Ensure tool is available in Bioconda
2. **Run Create Command**: Generate module scaffold
3. **Edit main.nf**: Implement process logic
4. **Update meta.yml**: Document inputs, outputs, parameters
5. **Write Tests**: Create nf-test test cases
6. **Lint Module**: Validate against standards
7. **Submit PR**: If contributing to nf-core/modules

## Module Naming

- Format: `tool` or `tool/subtool`
- Lowercase only
- Examples:
  - `fastqc` (single tool)
  - `bwa/mem` (tool with subtool)
  - `samtools/sort`, `samtools/index` (same tool, different operations)

## Generated Files

```
modules/nf-core/tool/subtool/
├── main.nf           # Process definition
├── meta.yml          # Metadata file
├── environment.yml   # Conda environment
└── tests/
    ├── main.nf.test      # nf-test tests
    ├── main.nf.test.snap # Test snapshots
    ├── nextflow.config   # Test config
    └── tags.yml          # Test tags
```

## main.nf Structure

```nextflow
process TOOL_SUBTOOL {
    tag "$meta.id"
    label 'process_single'  // or process_low, process_medium, process_high

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tool:version' :
        'quay.io/biocontainers/tool:version' }"

    input:
    tuple val(meta), path(input_file)

    output:
    tuple val(meta), path("*.out"), emit: output
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    tool subtool \\
        $args \\
        --input $input_file \\
        --output ${prefix}.out

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tool: \$(tool --version | sed 's/.*version //')
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

## meta.yml Structure

```yaml
name: tool_subtool
description: Brief description of what the tool does
keywords:
  - genomics
  - alignment
  - sorting
tools:
  - tool:
      description: Full description of the tool
      homepage: https://tool-homepage.com
      documentation: https://tool-docs.com
      tool_dev_url: https://github.com/tool/repo
      doi: "10.1093/bioinformatics/xyz"
      licence: ["MIT"]

input:
  - - meta:
        type: map
        description: |
          Groovy Map containing sample information
          e.g. `[ id:'sample1', single_end:false ]`
    - input_file:
        type: file
        description: Input file description
        pattern: "*.{bam,sam}"

output:
  - output:
      - meta:
          type: map
          description: Sample metadata
      - "*.out":
          type: file
          description: Output file description
          pattern: "*.out"
  - versions:
      - versions.yml:
          type: file
          description: File containing software versions
          pattern: "versions.yml"

authors:
  - "@github_username"
maintainers:
  - "@github_username"
```

## Process Labels

| Label | CPUs | Memory | Time |
|-------|------|--------|------|
| `process_single` | 1 | 6 GB | 4h |
| `process_low` | 2 | 12 GB | 4h |
| `process_medium` | 6 | 36 GB | 8h |
| `process_high` | 12 | 72 GB | 16h |
| `process_long` | 2 | 12 GB | 20h |
| `process_high_memory` | 10 | 200 GB | 12h |

## Container Sources

1. **Bioconda/Biocontainers** (preferred):
   ```nextflow
   container "${ workflow.containerEngine == 'singularity' ?
       'https://depot.galaxyproject.org/singularity/tool:1.0--h123' :
       'quay.io/biocontainers/tool:1.0--h123' }"
   ```

2. **Custom container**:
   ```nextflow
   container "docker.io/org/tool:version"
   ```

## Finding Container Versions

```bash
# Search Bioconda
conda search -c bioconda tool

# Search Biocontainers
curl -s "https://api.biocontainers.pro/ga4gh/trs/v2/tools/tool/versions" | jq

# Check quay.io
curl -s "https://quay.io/api/v1/repository/biocontainers/tool/tag/" | jq
```

## Lint Module

```bash
# Lint specific module
conda run -n nf-core nf-core modules lint tool/subtool

# Lint all modules
conda run -n nf-core nf-core modules lint --all
```

## Test Module

```bash
# Run tests
conda run -n nf-core nf-test test modules/nf-core/tool/subtool/

# Update snapshots
conda run -n nf-core nf-test test modules/nf-core/tool/subtool/ --update-snapshot
```

## Contributing to nf-core/modules

1. Fork nf-core/modules
2. Create module following guidelines
3. Run lint and tests
4. Open PR to nf-core/modules
5. Request review from modules-team
