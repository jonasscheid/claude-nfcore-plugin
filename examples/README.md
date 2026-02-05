# Example Workflow

This example demonstrates how to use the nf-claude-nfcore plugin in a Nextflow workflow.

## Usage

### Basic execution

```bash
nextflow run example_workflow.nf --input test_data.txt
```

### With custom parameters

```bash
nextflow run example_workflow.nf \
    --input test_data.txt \
    --outdir results \
    --max_cpus 8 \
    --max_memory '16.GB'
```

## Parameters

- `--input`: Input file to process (required)
- `--outdir`: Output directory (default: './results')
- `--max_cpus`: Maximum number of CPUs to use (default: 4)
- `--max_memory`: Maximum memory to use (default: '8.GB')

## Features Demonstrated

This example workflow demonstrates:

1. **Parameter Validation**: Shows how to validate required parameters
2. **nf-core Best Practices**: Follows nf-core standards for process naming and structure
3. **Resource Management**: Uses parameterized resource limits
4. **Output Organization**: Publishes results to organized directories
5. **Logging**: Comprehensive workflow start, completion, and error logging
6. **Error Handling**: Proper error handling and reporting

## Output Structure

```
results/
├── processed/
│   └── processed_<input_file>
├── final/
│   └── summary.txt
└── pipeline_info/
    ├── execution_timeline.html
    ├── execution_report.html
    ├── execution_trace.txt
    └── pipeline_dag.html
```

## Creating Test Data

To create a simple test file:

```bash
echo "Test data for nf-core plugin" > test_data.txt
```

## Notes

- This workflow uses Nextflow DSL2 syntax
- The plugin provides validation and workflow utilities
- All processes follow nf-core naming conventions (uppercase)
- Output is organized following best practices
