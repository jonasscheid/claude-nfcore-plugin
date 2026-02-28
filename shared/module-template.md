# nf-core Module Template Reference

Standard module structure and templates. Read by `modules` skill and `module-creator` agent.

## File Structure

```
modules/nf-core/tool/subtool/
├── main.nf           # Process definition
├── meta.yml          # Metadata
├── environment.yml   # Conda environment
└── tests/
    ├── main.nf.test      # nf-test tests
    ├── main.nf.test.snap # Snapshots
    ├── nextflow.config   # Test config
    └── tags.yml          # Tags
```

## main.nf Template

```nextflow
process TOOL_SUBTOOL {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tool:version--build' :
        'quay.io/biocontainers/tool:version--build' }"

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

## meta.yml Template

```yaml
name: tool_subtool
description: Brief description of what the tool does
keywords:
  - genomics
  - alignment
tools:
  - tool:
      description: Full tool description
      homepage: https://tool-homepage.com
      documentation: https://tool-docs.com
      tool_dev_url: https://github.com/org/tool
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
  - result:
      - meta:
          type: map
          description: Sample metadata
      - "${prefix}.out":
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

## Container Sources

1. **Bioconda/Biocontainers** (preferred):
   - Singularity: `https://depot.galaxyproject.org/singularity/TOOL:VERSION--BUILD`
   - Docker: `quay.io/biocontainers/TOOL:VERSION--BUILD`

2. **Finding versions**:
   ```bash
   # Search Bioconda
   <cmd_prefix> conda search -c bioconda tool
   # Check quay.io
   curl -s "https://quay.io/api/v1/repository/biocontainers/tool/tag/" | jq
   ```

## Module Naming

- Format: `tool` or `tool/subtool`
- Lowercase only
- Examples: `fastqc`, `bwa/mem`, `samtools/sort`
