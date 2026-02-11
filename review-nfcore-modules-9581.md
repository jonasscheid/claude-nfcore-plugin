# PR Review: nf-core/modules#9581

**Title:** RiboCode - add error handling where the cli tool does not
**Author:** JackCurragh
**URL:** https://github.com/nf-core/modules/pull/9581

## Summary

Adds error handling to `ribocode/metaplots` and `ribocode/ribocode` modules where the CLI tool silently produces invalid output instead of failing. Includes failure-mode nf-test cases.

## Issues

### 1. `|| true` swallows all failures (ribocode/main.nf) — Major

The original script had:

```bash
$args 2>&1 || test -s ${prefix}.txt
```

This allowed a non-zero exit only if the output file was missing/empty — a reasonable fallback. The PR replaces it with:

```bash
$args 2>&1 | tee ribocode_output.log || true
```

The `|| true` suppresses **all** exit codes, relying entirely on grepping for `Error` strings in the log. If RiboCode segfaults, OOMs, or produces an error in an unexpected format, the process will silently succeed with missing or empty output files. This is a regression in robustness. Consider combining both approaches:

```bash
$args 2>&1 | tee ribocode_output.log || true

if grep -qiE "^Error|Error:" ribocode_output.log; then
    ...
    exit 1
fi

# Fallback: ensure output was actually produced
if [ ! -s ${prefix}.txt ]; then
    echo "ERROR: RiboCode produced no output." >&2
    exit 1
fi
```

### 2. Test assertions check `process.stdout` but errors go to stderr — Minor/Verify

Both failure tests assert:

```groovy
{ assert process.stdout.toString().contains("ERROR: ...") }
```

But the error messages are written to stderr (`>&2`). If CI passed, this may be an nf-test framework behavior where both streams are captured in `process.stdout`, but it is worth verifying. If these assertions are silently passing for the wrong reason (e.g., the test passes because `!process.success` is true and the stdout assertion is vacuously grouped in `assertAll`), the test coverage is weaker than it appears.

### 3. Intermediate log file not cleaned up — Minor

`tee ribocode_output.log` creates a file in the work directory that is neither declared as an output nor removed. It won't affect results but wastes disk space, particularly on cloud executors where work directory storage has cost implications.

### 4. Broad output glob `path("*.txt")` in ribocode/main.nf — Pre-existing, not from this PR

The output declaration `path("*.txt")` could capture unintended files (e.g., if any staged input happens to be `.txt`). nf-core best practice is to use prefix-scoped patterns like `path("${prefix}*.txt")` to avoid unnecessary file copies on cloud storage. Not introduced by this PR, but worth noting for a follow-up.

## What looks good

- Error messages are informative and actionable, referencing `ext.args` instead of pipeline-specific parameters — correct for reusable modules.
- The `metaplots` validation logic (`grep -qE '^[^#[:space:]]'`) correctly distinguishes header-only output from actual data.
- Failure-mode tests with a dedicated `nextflow_fail.config` is a good pattern.
- Standard nf-core conventions are followed: `tag "$meta.id"`, `label 'process_single'`, `task.ext.when` guard, topic-based version emission, proper container definitions.

## Verdict

The error handling intent is sound and addresses a real problem with silent failures. The main concern is that `|| true` is overly permissive and could mask non-Error failures. Adding a fallback output-existence check would make this robust. Recommend addressing issue #1 before merge.
