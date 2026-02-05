---
name: samplesheet-create
description: Create and validate samplesheets for nf-core pipelines. Use when preparing input data, creating sample manifests, debugging samplesheet errors, or understanding pipeline input requirements.
argument-hint: "[pipeline-name] [--format csv|tsv|yaml]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash(conda run -n nf-core *)
  - WebFetch(nf-co.re/*)
---

# nf-core Samplesheet Creation

Create and validate input samplesheets for nf-core pipelines.

## Quick Process

1. **Identify Pipeline**: Know which pipeline you're creating a samplesheet for
2. **Check Schema**: Find the samplesheet schema in `assets/schema_input.json`
3. **Create Template**: Generate CSV/TSV with required columns
4. **Populate Data**: Add your sample information
5. **Validate**: Run pipeline with `--input` to validate

## Common Samplesheet Formats

### RNA-seq (nf-core/rnaseq)

```csv
sample,fastq_1,fastq_2,strandedness
SAMPLE1,/path/to/sample1_R1.fastq.gz,/path/to/sample1_R2.fastq.gz,auto
SAMPLE2,/path/to/sample2_R1.fastq.gz,/path/to/sample2_R2.fastq.gz,auto
SAMPLE3_SE,/path/to/sample3.fastq.gz,,auto
```

### ATAC-seq (nf-core/atacseq)

```csv
sample,fastq_1,fastq_2,replicate
SAMPLE1,/path/to/sample1_R1.fastq.gz,/path/to/sample1_R2.fastq.gz,1
SAMPLE1,/path/to/sample1_rep2_R1.fastq.gz,/path/to/sample1_rep2_R2.fastq.gz,2
SAMPLE2,/path/to/sample2_R1.fastq.gz,/path/to/sample2_R2.fastq.gz,1
```

### Variant Calling (nf-core/sarek)

```csv
patient,sex,status,sample,lane,fastq_1,fastq_2
PATIENT1,XX,0,SAMPLE1_NORMAL,lane1,/path/to/normal_R1.fastq.gz,/path/to/normal_R2.fastq.gz
PATIENT1,XX,1,SAMPLE1_TUMOR,lane1,/path/to/tumor_R1.fastq.gz,/path/to/tumor_R2.fastq.gz
```

### Metagenomics (nf-core/mag)

```csv
sample,group,short_reads_1,short_reads_2,long_reads
SAMPLE1,GROUP1,/path/to/sample1_R1.fastq.gz,/path/to/sample1_R2.fastq.gz,
SAMPLE2,GROUP1,/path/to/sample2_R1.fastq.gz,/path/to/sample2_R2.fastq.gz,/path/to/sample2.ont.fastq.gz
```

### Amplicon (nf-core/ampliseq)

```csv
sampleID,forwardReads,reverseReads,run
SAMPLE1,/path/to/sample1_R1.fastq.gz,/path/to/sample1_R2.fastq.gz,run1
SAMPLE2,/path/to/sample2_R1.fastq.gz,/path/to/sample2_R2.fastq.gz,run1
```

## Finding Schema Requirements

### Check Pipeline Documentation
```bash
# Visit pipeline page
# e.g., https://nf-co.re/rnaseq/usage#samplesheet-input
```

### Check Schema File
```bash
# Look for input schema
cat assets/schema_input.json
```

### Check nextflow_schema.json
```bash
# Find input parameter schema reference
grep -A5 '"input"' nextflow_schema.json
```

## Schema Structure

Input schemas define columns:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "array",
  "items": {
    "type": "object",
    "required": ["sample", "fastq_1"],
    "properties": {
      "sample": {
        "type": "string",
        "pattern": "^\\S+$",
        "description": "Sample name"
      },
      "fastq_1": {
        "type": "string",
        "format": "file-path",
        "exists": true,
        "description": "Path to R1 FASTQ"
      },
      "fastq_2": {
        "type": "string",
        "format": "file-path",
        "exists": true,
        "description": "Path to R2 FASTQ (optional)"
      },
      "strandedness": {
        "type": "string",
        "enum": ["auto", "forward", "reverse", "unstranded"],
        "description": "Strandedness"
      }
    }
  }
}
```

## Generating Samplesheets

### From File Listing
```bash
# Generate from directory of FASTQs
for f in *_R1.fastq.gz; do
    sample=$(basename "$f" _R1.fastq.gz)
    r2="${sample}_R2.fastq.gz"
    echo "${sample},$(pwd)/${f},$(pwd)/${r2},auto"
done > samplesheet.csv

# Add header
sed -i '1i sample,fastq_1,fastq_2,strandedness' samplesheet.csv
```

### From Manifest
```bash
# If you have a manifest file
awk -F'\t' 'NR>1 {print $1","$2","$3",auto"}' manifest.tsv > samplesheet.csv
```

## Validation

### Using nf-schema
When pipeline uses nf-schema, validation happens automatically:

```bash
nextflow run nf-core/rnaseq --input samplesheet.csv -profile test,docker
# Validation errors shown immediately
```

### Manual Validation
```bash
# Check file exists
while IFS=, read -r sample fastq_1 fastq_2 strand; do
    [ -f "$fastq_1" ] || echo "Missing: $fastq_1"
    [ -n "$fastq_2" ] && [ ! -f "$fastq_2" ] && echo "Missing: $fastq_2"
done < <(tail -n +2 samplesheet.csv)
```

## Common Issues

### "File not found"
- Use absolute paths
- Check file permissions
- Verify file extensions match exactly

### "Invalid sample name"
- No spaces in sample names
- Use alphanumeric and underscores
- Match pattern in schema

### "Missing required column"
- Check column names match exactly (case-sensitive)
- Include all required columns

### "Invalid value"
- Check enum values match allowed options
- Verify numeric values are in range

## Best Practices

1. **Use absolute paths**: `/full/path/to/file.fastq.gz`
2. **Consistent naming**: Follow pipeline conventions
3. **No special characters**: Avoid spaces, quotes in values
4. **Validate early**: Test with one sample first
5. **Document samples**: Keep metadata in separate file
6. **Version control**: Track samplesheet in git

## Converting Formats

### CSV to TSV
```bash
sed 's/,/\t/g' samplesheet.csv > samplesheet.tsv
```

### TSV to CSV
```bash
sed 's/\t/,/g' samplesheet.tsv > samplesheet.csv
```

### Excel to CSV
- Save As → CSV UTF-8
- Or use: `xlsx2csv samplesheet.xlsx > samplesheet.csv`
