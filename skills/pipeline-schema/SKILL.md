---
name: pipeline-schema
description: Manage the nextflow_schema.json file for pipeline parameters. Use when adding/modifying parameters, building/validating schema, generating documentation, or working with pipeline configuration.
argument-hint: "[build|lint|validate|docs]"
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Edit
  - Write
  - Glob
---

# nf-core Pipeline Schema Management

Manage the `nextflow_schema.json` file that defines pipeline parameters following JSONSchema Draft 7 specification.

## Quick Commands

```bash
# Build/update schema from nextflow.config
conda run -n nf-core nf-core pipelines schema build

# Build with web interface only (no prompts)
conda run -n nf-core nf-core pipelines schema build --web-only

# Lint schema for errors
conda run -n nf-core nf-core pipelines schema lint

# Validate a params file against schema
conda run -n nf-core nf-core pipelines schema validate <pipeline> params.json

# Generate documentation from schema
conda run -n nf-core nf-core pipelines schema docs nextflow_schema.json --output params.md
conda run -n nf-core nf-core pipelines schema docs nextflow_schema.json --output params.md --format markdown
```

## Process

1. **Define Parameters**: Add params to `nextflow.config`
2. **Build Schema**: Run `nf-core pipelines schema build` to generate/update
3. **Organize in Web UI**: Use the web interface to organize into groups
4. **Add Descriptions**: Document each parameter
5. **Lint**: Validate schema structure
6. **Test**: Validate sample params files

## Schema Structure

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://raw.githubusercontent.com/nf-core/mypipeline/master/nextflow_schema.json",
  "title": "nf-core/mypipeline pipeline parameters",
  "description": "Pipeline description",
  "type": "object",
  "defs": {
    "input_output_options": {
      "title": "Input/output options",
      "type": "object",
      "fa_icon": "fas fa-terminal",
      "description": "Define input and output paths",
      "required": ["input", "outdir"],
      "properties": {
        "input": {
          "type": "string",
          "format": "file-path",
          "exists": true,
          "mimetype": "text/csv",
          "pattern": "^\\S+\\.csv$",
          "description": "Path to samplesheet",
          "fa_icon": "fas fa-file-csv"
        },
        "outdir": {
          "type": "string",
          "format": "directory-path",
          "description": "Output directory",
          "fa_icon": "fas fa-folder-open",
          "default": "./results"
        }
      }
    }
  },
  "allOf": [
    { "$ref": "#/defs/input_output_options" }
  ]
}
```

## Parameter Types

| Type | Example | Use Case |
|------|---------|----------|
| `string` | `"value"` | Text, paths, enums |
| `integer` | `10` | Whole numbers |
| `number` | `0.05` | Decimals |
| `boolean` | `true/false` | Flags |
| `object` | `{}` | Complex structures |
| `array` | `[]` | Lists |

## Parameter Formats

For string types, use formats:

```json
{
  "input": {
    "type": "string",
    "format": "file-path",
    "exists": true
  },
  "outdir": {
    "type": "string",
    "format": "directory-path"
  },
  "email": {
    "type": "string",
    "format": "email"
  }
}
```

## Common Parameter Groups

Standard nf-core parameter organization:

1. **Input/output options**: `--input`, `--outdir`
2. **Reference genome options**: `--genome`, `--fasta`
3. **Analysis options**: Pipeline-specific params
4. **Process skipping options**: `--skip_*` flags
5. **Institutional config options**: `--config_profile_*`
6. **Max job request options**: `--max_cpus`, `--max_memory`, `--max_time`
7. **Generic options**: `--help`, `--version`, `--publish_dir_mode`

## Naming Conventions

- **snake_case**: `input_file` not `inputFile`
- **Boolean negatives**: `skip_qc` not `run_qc`
- **Descriptive**: `min_read_length` not `minlen`

## Adding a New Parameter

1. **Add to nextflow.config**:
   ```nextflow
   params {
       // Analysis options
       min_quality = 20
   }
   ```

2. **Run schema build**:
   ```bash
   conda run -n nf-core nf-core pipelines schema build
   ```

3. **Answer prompts** or use web UI to:
   - Set type (integer)
   - Add description
   - Set minimum/maximum values
   - Choose icon
   - Assign to group

4. **Resulting schema entry**:
   ```json
   "min_quality": {
     "type": "integer",
     "default": 20,
     "minimum": 0,
     "maximum": 40,
     "description": "Minimum base quality score",
     "fa_icon": "fas fa-chart-bar"
   }
   ```

## Validation with nf-schema

In your workflow, validate params:

```nextflow
include { validateParameters; paramsSummaryLog } from 'plugin/nf-schema'

// Validate parameters
validateParameters()

// Log parameter summary
log.info paramsSummaryLog(workflow)
```

## Samplesheet Schema

Define samplesheet columns in a separate schema file referenced from the parameter:

```json
"input": {
  "type": "string",
  "format": "file-path",
  "schema": "assets/schema_input.json",
  "description": "Path to samplesheet"
}
```

## Common Issues

### Parameter Not in Schema
Run `nf-core pipelines schema build` to add new params

### Type Mismatch
Ensure config default matches schema type

### Missing Required Fields
Add `"required": ["param1", "param2"]` to definitions

### Validation Failure
Check param values against schema constraints (min, max, enum, pattern)
