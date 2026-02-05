---
name: module-install
description: Install modules from nf-core/modules repository into your pipeline. Use when adding new tools/processes to a pipeline, when the user wants to install a module, or when setting up analysis steps.
argument-hint: "[module-name]"
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Glob
  - Grep
---

# nf-core Module Installation

Install pre-built modules from the nf-core/modules repository into your pipeline.

## Quick Commands

```bash
# List all available remote modules
conda run -n nf-core nf-core modules list remote

# Search for a specific module
conda run -n nf-core nf-core modules list remote | grep -i "tool_name"

# List installed modules in current pipeline
conda run -n nf-core nf-core modules list local

# Install a module
conda run -n nf-core nf-core modules install <tool/subtool>

# Install specific version
conda run -n nf-core nf-core modules install <module> --sha <commit_sha>

# Force reinstall
conda run -n nf-core nf-core modules install <module> --force

# Get module info
conda run -n nf-core nf-core modules info <module>
```

## Process

1. **Identify Module**: Search for the module by tool name
2. **Check Availability**: Verify module exists in nf-core/modules
3. **Review Info**: Check module documentation with `nf-core modules info`
4. **Install**: Run the install command
5. **Integrate**: Add the module to your workflow

## Module Naming Convention

Modules use the format `tool/subtool`:
- `fastqc` - Single tool
- `bwa/mem` - Tool with subtool
- `samtools/sort` - Tool with subtool
- `samtools/index` - Same tool, different subtool

## Installation Location

Modules are installed to:
```
modules/nf-core/<tool>/<subtool>/
├── main.nf          # Process definition
├── meta.yml         # Metadata (inputs, outputs, params)
└── tests/
    ├── main.nf.test # nf-test tests
    └── main.nf.test.snap # Test snapshots
```

## Integration Example

After installing a module like `fastqc`:

```nextflow
// In your workflow file
include { FASTQC } from '../modules/nf-core/fastqc/main'

workflow MY_WORKFLOW {
    take:
    reads  // channel: [ val(meta), path(reads) ]

    main:
    FASTQC ( reads )

    emit:
    zip   = FASTQC.out.zip   // channel: [ val(meta), path(zip) ]
    html  = FASTQC.out.html  // channel: [ val(meta), path(html) ]
}
```

## Using ext.args for Tool Arguments

Pass additional arguments to tools via `ext.args` in your config:

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

## Popular Modules

| Module | Purpose |
|--------|---------|
| `fastqc` | Read quality control |
| `multiqc` | Report aggregation |
| `trimgalore` | Adapter and quality trimming |
| `bwa/mem` | Read alignment |
| `bwa/mem2` | Faster read alignment |
| `samtools/sort` | BAM sorting |
| `samtools/index` | BAM indexing |
| `samtools/stats` | BAM statistics |
| `bcftools/call` | Variant calling |
| `gatk4/markduplicates` | Duplicate marking |

## Troubleshooting

### Module Not Found
```bash
# Update modules list
conda run -n nf-core nf-core modules list remote --update

# Check exact name
conda run -n nf-core nf-core modules list remote | grep -i "partial_name"
```

### Version Conflicts
```bash
# Check installed version
conda run -n nf-core nf-core modules list local

# Update to latest
conda run -n nf-core nf-core modules update <module>

# Install specific version
conda run -n nf-core nf-core modules install <module> --sha <commit>
```
