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

# Run with specific profile
conda run -n nf-core nf-test test --profile docker
conda run -n nf-core nf-test test --profile singularity
conda run -n nf-core nf-test test --profile conda

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

## Testing Workflows

```groovy
nextflow_workflow {

    name "Test Workflow MYWORKFLOW"
    script "../../../workflows/myworkflow.nf"
    workflow "MYWORKFLOW"

    test("Should run with test data") {
        when {
            workflow {
                """
                input[0] = Channel.fromPath(params.input)
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
    // Test directory
    testsDir "tests"

    // Work directory for test runs
    workDir ".nf-test"

    // Config file to use
    configFile "conf/test.config"

    // Default profile
    profile "docker"
}
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
