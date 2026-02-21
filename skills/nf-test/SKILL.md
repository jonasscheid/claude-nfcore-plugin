---
name: nf-test
description: Run and manage nf-test tests for Nextflow pipelines and modules. Use when testing workflows, creating test cases, debugging test failures, updating snapshots, or validating pipeline outputs.
argument-hint: "[test-path] [--profile docker|singularity|conda]"
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# nf-test Testing for nf-core

Run and manage tests using the nf-test framework for Nextflow pipelines and modules.

## Quick Commands

```bash
# Run all tests
conda run -n nf-core nf-test test

# Run tests for specific file/directory
conda run -n nf-core nf-test test tests/modules/fastqc/

# Run with container profile (+ prefix ADDS to test profile, without + it REPLACES)
conda run -n nf-core nf-test test --profile +docker
conda run -n nf-core nf-test test --profile +singularity
conda run -n nf-core nf-test test --profile +conda

# Run tests matching a tag
conda run -n nf-core nf-test test --tag "modules"

# Update snapshots
conda run -n nf-core nf-test test --update-snapshot

# Run with verbose output
conda run -n nf-core nf-test test --verbose

# List available tests
conda run -n nf-core nf-test list
```

## Test File Structure

nf-test files use `.nf.test` extension:

```groovy
// tests/modules/fastqc/main.nf.test
nextflow_process {

    name "Test Process FASTQC"
    script "../../../modules/nf-core/fastqc/main.nf"
    process "FASTQC"

    tag "modules"
    tag "fastqc"

    test("Single-end reads") {
        when {
            process {
                """
                input[0] = [
                    [ id:'test', single_end:true ],
                    file(params.test_data['sarscov2']['illumina']['test_1_fastq_gz'], checkIfExists: true)
                ]
                """
            }
        }

        then {
            assert process.success
            assert snapshot(process.out).match()
        }
    }

    test("Paired-end reads") {
        when {
            process {
                """
                input[0] = [
                    [ id:'test', single_end:false ],
                    [
                        file(params.test_data['sarscov2']['illumina']['test_1_fastq_gz'], checkIfExists: true),
                        file(params.test_data['sarscov2']['illumina']['test_2_fastq_gz'], checkIfExists: true)
                    ]
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

## Snapshot Testing

Snapshots capture output for comparison in future runs:

```groovy
then {
    // Snapshot all outputs
    assert snapshot(process.out).match()

    // Snapshot specific output channel
    assert snapshot(process.out.html).match()

    // Snapshot with custom name
    assert snapshot(process.out.zip).match("fastqc_zip_output")

    // Snapshot file contents
    assert snapshot(path(process.out.html[0][1]).readLines()[0..5]).match()
}
```

Snapshot files are stored as `.nf.test.snap` alongside test files.

## Common Assertions

```groovy
then {
    // Check process succeeded
    assert process.success

    // Check process failed (for error testing)
    assert process.failed

    // Check exit code
    assert process.exitStatus == 0

    // Check output exists
    assert process.out.html

    // Check output count
    assert process.out.html.size() == 1

    // Check file exists
    assert path(process.out.html[0][1]).exists()

    // Check file content
    assert path(process.out.html[0][1]).text.contains("FastQC")

    // Check file MD5
    assert path(process.out.html[0][1]).md5 == "expected_md5_hash"

    // Check versions.yml
    assert snapshot(process.out.versions).match()
}
```

## Testing Subworkflows

```groovy
nextflow_workflow {

    name "Test Workflow MYWORKFLOW"
    script "../../../workflows/myworkflow.nf"
    workflow "MYWORKFLOW"

    test("Should run with test data") {
        when {
            workflow {
                """
                input[0] = channel.fromPath(params.input)
                """
            }
        }

        then {
            assert workflow.success
            assert snapshot(workflow.out).match()
        }
    }
}
```

## Pipeline-Level Tests

Pipeline tests use `nextflow_pipeline` and load params via profiles from `conf/test_XYZ.config`.
**Params are NEVER defined inline** — they belong in the config file.

### Required Setup

1. **`conf/test_XYZ.config`** — defines all test params (inputs, flags, resources)
2. **`nextflow.config` profiles** — maps `test_XYZ { includeConfig 'conf/test_XYZ.config' }`
3. **`nf-test.config`** — sets `profile "test"` as default
4. **`tests/nextflow.config`** — shared test data base paths

### Default Pipeline Test

```groovy
// tests/default.nf.test
nextflow_pipeline {

    name "Test pipeline"
    script "../main.nf"
    tag "pipeline"

    test("-profile test") {

        when {
            params {
                outdir = "$outputDir"
            }
        }

        then {
            def stable_name = getAllFilesFromDir(params.outdir, relative: true, includeDir: true, ignore: ['pipeline_info/*.{html,json,txt}'])
            def stable_path = getAllFilesFromDir(params.outdir, ignoreFile: 'tests/.nftignore')
            assertAll(
                { assert workflow.success },
                { assert snapshot(
                    removeNextflowVersion("$outputDir/pipeline_info/nf_core_pipeline_software_mqc_versions.yml"),
                    stable_name,
                    stable_path
                ).match() }
            )
        }
    }
}
```

### Variant Pipeline Test (Override Profile)

```groovy
// tests/foo.nf.test — uses conf/test_foo.config via profile
nextflow_pipeline {

    name "Test pipeline"
    script "../main.nf"
    tag "pipeline"
    tag "test_foo"
    profile "test_foo"

    test("-profile test_foo") {

        when {
            params {
                outdir = "$outputDir"
            }
        }

        then {
            def stable_name = getAllFilesFromDir(params.outdir, relative: true, includeDir: true, ignore: ['pipeline_info/*.{html,json,txt}'])
            def stable_path = getAllFilesFromDir(params.outdir, ignoreFile: 'tests/.nftignore')
            assertAll(
                { assert workflow.success },
                { assert snapshot(
                    workflow.trace.succeeded().size(),
                    removeNextflowVersion("$outputDir/pipeline_info/nf_core_pipeline_software_mqc_versions.yml"),
                    stable_name,
                    stable_path
                ).match() }
            )
        }
    }
}
```

### Key Rules

- **`nextflow_pipeline`** for pipeline tests, `nextflow_workflow` for subworkflows
- **`profile` directive only works with `nextflow_pipeline`** — it is silently ignored in `nextflow_workflow` and `nextflow_process`
- **Only `outdir`** in the `when` block — all other params come from the profile config
- **`profile "test_XYZ"`** at the `nextflow_pipeline` level overrides the default
- **Test name = profile**: `test("-profile test_XYZ")`
- **CLI `--profile` uses `+` prefix** to add to test profile: `--profile +docker` gives `-profile test_XYZ,docker`. Without `+`, CLI replaces the test profile entirely
- Use `nft-utils` plugin for `getAllFilesFromDir` and `removeNextflowVersion`

## Stub Runs for Large Data

When test data is too large, use stub runs:

```groovy
test("Stub run") {
    options "-stub"

    when {
        process {
            """
            input[0] = [ [ id:'test' ], file('dummy.bam') ]
            """
        }
    }

    then {
        assert process.success
        assert snapshot(process.out).match()
    }
}
```

Define stubs in your module's `main.nf`:

```nextflow
process TOOL {
    // ... normal process definition ...

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam
    touch ${prefix}.bam.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tool: 1.0.0
    END_VERSIONS
    """
}
```

## Configuration

Create `nf-test.config` in your pipeline root:

```groovy
config {
    // location for all nf-test tests
    testsDir "."

    // nf-test directory including temporary files for each test
    workDir System.getenv("NFT_WORKDIR") ?: ".nf-test"

    // location of an optional nextflow.config file specific for executing tests
    configFile "tests/nextflow.config"

    // ignore tests coming from the nf-core/modules repo
    ignore 'modules/nf-core/**/tests/*', 'subworkflows/nf-core/**/tests/*'

    // run all tests with default profile from the main nextflow.config
    profile "test"

    // list of filenames or patterns that should trigger a full test run
    triggers 'nextflow.config', 'nf-test.config', 'conf/test.config', 'tests/nextflow.config', 'tests/.nftignore'

    // load the necessary plugins
    plugins {
        load "nft-utils@0.0.3"
    }
}
```

### `tests/nextflow.config` — Shared Test Base Paths

```nextflow
params {
    modules_testdata_base_path = 'https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/'
    pipelines_testdata_base_path = 'https://raw.githubusercontent.com/nf-core/test-datasets/refs/heads/PIPELINE_NAME'
}

aws.client.anonymous = true
```

## Debugging Test Failures

1. **Run with verbose output**:
   ```bash
   conda run -n nf-core nf-test test --verbose tests/path/main.nf.test
   ```

2. **Check work directory**:
   - Look in `.nf-test/` for execution logs
   - Check `.command.err` and `.command.log` files

3. **Update snapshots if outputs legitimately changed**:
   ```bash
   conda run -n nf-core nf-test test --update-snapshot tests/path/main.nf.test
   ```

4. **Review snapshot diffs**:
   - Compare `.nf.test.snap` files in git diff
   - Ensure changes are expected

## Best Practices

1. **Test all outputs**: Include assertions for every output channel
2. **Use meaningful test names**: Describe what's being tested
3. **Tag tests**: Use tags for filtering (`tag "modules"`, `tag "slow"`)
4. **Minimal test data**: Use smallest datasets that exercise the code
5. **Version snapshots**: Commit `.nf.test.snap` files with code
6. **Review snapshot changes**: Part of code review process
