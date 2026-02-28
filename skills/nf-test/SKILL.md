---
name: nf-test
description: Run and manage nf-test tests for Nextflow pipelines and modules. Use when testing workflows, creating test cases, debugging test failures, updating snapshots, or validating pipeline outputs.
argument-hint: "[test-path] [--profile docker|singularity|conda]"
allowed-tools:
  - Bash(conda run *)
  - Bash(nf-core *)
  - Bash(nf-test *)
  - Bash(nextflow *)
  - Bash(uv run *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# nf-test Testing

Run and manage tests using nf-test for Nextflow pipelines and modules.

Read `${CLAUDE_PLUGIN_ROOT}/shared/conventions.md` for nf-core conventions and package manager setup.
Read `${CLAUDE_PLUGIN_ROOT}/shared/test-patterns.md` for test templates and patterns.

---

## Quick Commands

Replace `<cmd>` with the configured package manager prefix (see Setup in conventions.md).

```bash
<cmd> nf-test test                                # Run all tests
<cmd> nf-test test tests/modules/fastqc/           # Specific path
<cmd> nf-test test --profile +docker               # Add container profile (+ ADDS, no + REPLACES)
<cmd> nf-test test --tag "modules"                  # Filter by tag
<cmd> nf-test test --update-snapshot                # Update snapshots
<cmd> nf-test test --verbose                        # Verbose output
<cmd> nf-test list                                  # List available tests
```

---

## Process Tests

```groovy
nextflow_process {
    name "Test Process FASTQC"
    script "../main.nf"
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

    test("Stub run") {
        options "-stub"
        when {
            process {
                """
                input[0] = [ [ id:'test' ], file('dummy.fastq.gz') ]
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

---

## Pipeline-Level Tests

Pipeline tests use `nextflow_pipeline` (NOT `nextflow_workflow`) and load params via profiles.
**Params are NEVER defined inline** — they go in `conf/test_XYZ.config`.

### Required Setup

1. **`conf/test_XYZ.config`** — all test params (inputs, flags, resources)
2. **`nextflow.config` profiles** — `test_XYZ { includeConfig 'conf/test_XYZ.config' }`
3. **`nf-test.config`** — `profile "test"` as default
4. **`tests/nextflow.config`** — shared test data base paths

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

1. **`nextflow_pipeline`** for pipeline tests — `profile` is silently ignored in `nextflow_workflow`/`nextflow_process`
2. **Params in `conf/test_XYZ.config`** — never inline in nf-test file
3. **Only `outdir`** in the `when` block
4. **`profile "test_XYZ"`** at `nextflow_pipeline` level overrides default
5. **Test name = profile**: `test("-profile test_XYZ")`
6. **CLI `--profile` uses `+` prefix**: `--profile +docker` adds to test profile; without `+` replaces
7. **`nft-utils` plugin**: For `getAllFilesFromDir`, `removeNextflowVersion`

---

## Snapshot Testing

```groovy
then {
    // Snapshot all outputs
    assert snapshot(process.out).match()

    // Snapshot specific channel
    assert snapshot(process.out.bam).match()

    // Snapshot with custom name
    assert snapshot(process.out.zip).match("fastqc_zip_output")

    // Filter non-deterministic content before snapshotting
    assert snapshot(path(process.out.log[0][1]).readLines().findAll { !it.startsWith('#') }).match()
}
```

### Snapshot Verification

After `--update-snapshot`, compare against the reference branch and present a summary table:

| Test | Files | Results | Match |
|------|-------|---------|-------|
| **default** | 71 = 71 | 252 = 252 | 100% |

Do not dismiss snapshot changes as stochastic — many pipelines use fixed seeds.

---

## Common Assertions

```groovy
assert process.success                              // Process succeeded
assert process.failed                                // Process failed (error testing)
assert process.out.html                              // Output exists
assert process.out.html.size() == 1                  // Output count
assert path(process.out.html[0][1]).exists()          // File exists
assert path(process.out.html[0][1]).text.contains("FastQC")  // Content check
assert path(process.out.bam[0][1]).md5 == 'hash'     // MD5 check
assert process.out.result[0][0].id == 'test'          // Metadata preserved
```

---

## Stub Runs

For large-data tools, use stub tests:

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

Requires `stub:` block in process main.nf — see module template.

---

## nf-test.config

```groovy
config {
    testsDir "."
    workDir System.getenv("NFT_WORKDIR") ?: ".nf-test"
    configFile "tests/nextflow.config"
    ignore 'modules/nf-core/**/tests/*', 'subworkflows/nf-core/**/tests/*'
    profile "test"
    triggers 'nextflow.config', 'nf-test.config', 'conf/test.config', 'tests/nextflow.config', 'tests/.nftignore'
    plugins {
        load "nft-utils@0.0.3"
    }
}
```

### tests/nextflow.config

```nextflow
params {
    modules_testdata_base_path = 'https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/'
    pipelines_testdata_base_path = 'https://raw.githubusercontent.com/nf-core/test-datasets/refs/heads/PIPELINE_NAME'
}
aws.client.anonymous = true
```

---

## Debugging Test Failures

1. **Verbose output**: `<cmd> nf-test test --verbose tests/path/main.nf.test`
2. **Check work directory**: Look in `.nf-test/` for `.command.err` and `.command.log`
3. **Update snapshots**: `<cmd> nf-test test --update-snapshot tests/path/main.nf.test`
4. **Review snapshot diffs**: Compare `.nf.test.snap` files in git diff
