# nf-test Patterns Reference

Test patterns for nf-core pipelines and modules. Read by `nf-test` skill and `test-writer` agent.

## Pipeline-Level Test Pattern

Pipeline tests use `nextflow_pipeline` (NOT `nextflow_workflow`) and load params via profiles.

### Architecture

```
nextflow.config          # profiles { test_XYZ { includeConfig 'conf/test_XYZ.config' } }
├── conf/test.config     # Default test params
├── conf/test_foo.config # Variant test params
nf-test.config           # profile "test" (default)
tests/
├── nextflow.config      # Shared test data base paths
├── default.nf.test      # Uses default profile
└── foo.nf.test          # Overrides to test_foo profile
```

### Default Pipeline Test

```groovy
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
        then { /* same assertion pattern */ }
    }
}
```

### Key Rules

1. **`nextflow_pipeline`** for pipeline tests — `profile` is silently ignored in `nextflow_workflow`/`nextflow_process`
2. **Params in `conf/test_XYZ.config`** — never inline in the nf-test file
3. **Only `outdir`** in the `when` block
4. **`profile "test_XYZ"`** at `nextflow_pipeline` level overrides default
5. **Test name = profile**: `test("-profile test_XYZ")`
6. **CLI `--profile` uses `+` prefix**: `--profile +docker` adds to test profile; without `+` it replaces

## Process Test Structure

```groovy
nextflow_process {
    name "Test Process TOOL_SUBTOOL"
    script "../main.nf"
    process "TOOL_SUBTOOL"

    tag "modules"
    tag "tool"
    tag "tool/subtool"

    test("description - input type") {
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

    test("stub run") {
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
}
```

## Common Assertions

```groovy
// Process success/failure
assert process.success
assert process.failed

// Snapshot all outputs
assert snapshot(process.out).match()

// Snapshot specific channel
assert snapshot(process.out.bam).match()

// File content checks
assert path(process.out.html[0][1]).text.contains("FastQC")
assert path(process.out.txt[0][1]).readLines().size() > 10

// MD5 check (deterministic outputs)
assert path(process.out.bam[0][1]).md5 == 'expected_hash'

// Metadata preserved
assert process.out.result[0][0].id == 'test'
```

## Snapshot Verification

After `--update-snapshot`, compare against the reference branch and present a summary table:

| Test | Files | Results | Match |
|------|-------|---------|-------|
| **default** | 71 = 71 | 252 = 252 | 100% |

Do not dismiss snapshot changes as stochastic — many pipelines use fixed seeds.
