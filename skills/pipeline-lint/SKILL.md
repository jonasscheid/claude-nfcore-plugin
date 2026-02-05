---
name: pipeline-lint
description: Lint an nf-core pipeline to validate against community guidelines. Use when checking pipeline compliance, before commits, before releases, or when the user wants to validate their pipeline. Can automatically fix many issues.
argument-hint: "[--fix] [directory]"
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Grep
  - Glob
  - Edit
---

# nf-core Pipeline Linting

Validate pipelines against nf-core community guidelines and automatically fix issues where possible.

## Quick Commands

```bash
# Lint current directory
conda run -n nf-core nf-core pipelines lint

# Lint with automatic fixes
conda run -n nf-core nf-core pipelines lint --fix

# Lint specific directory
conda run -n nf-core nf-core pipelines lint --dir /path/to/pipeline

# Run specific tests only
conda run -n nf-core nf-core pipelines lint -k files_exist -k files_unchanged

# Show all results including passed
conda run -n nf-core nf-core pipelines lint --show-passed

# Output as JSON/Markdown
conda run -n nf-core nf-core pipelines lint --json
conda run -n nf-core nf-core pipelines lint --markdown
```

## Process

1. **Run Initial Lint**: Execute `conda run -n nf-core nf-core pipelines lint` to identify all issues
2. **Parse Results**: Categorize into PASSED, WARNED, and FAILED tests
3. **Prioritize Fixes**: Address FAILED tests first, then WARNED
4. **Apply Automatic Fixes**: Use `--fix` flag for supported issues (requires git repo with no uncommitted changes)
5. **Manual Fixes**: Guide through fixes that require manual intervention
6. **Verify**: Re-run lint to confirm all issues are resolved

## Common Lint Categories

| Category | Description |
|----------|-------------|
| `files_exist` | Required files like LICENSE, CITATIONS.md, CODE_OF_CONDUCT.md |
| `files_unchanged` | Template files that shouldn't be modified significantly |
| `nextflow_config` | Configuration file validation (manifest, params, profiles) |
| `schema_lint` | nextflow_schema.json structure and validation |
| `actions_ci` | GitHub Actions CI configuration |
| `readme` | README.md required sections and content |
| `pipeline_todos` | TODO comments that should be addressed |
| `version_consistency` | Version numbers match across files |

## Configuring Lint Tests

Create or edit `.nf-core.yml` in your pipeline root to disable specific tests:

```yaml
lint:
  # Disable entire tests
  actions_awsfulltest: False
  pipeline_todos: False

  # Skip specific files for a test
  files_exist:
    - CODE_OF_CONDUCT.md
  files_unchanged:
    - assets/email_template.html
    - .github/CONTRIBUTING.md
```

## Common Fixes

### Missing Files
If `files_exist` fails, create the missing files. Common ones:
- `LICENSE` - MIT license text
- `CODE_OF_CONDUCT.md` - Community code of conduct
- `CITATIONS.md` - Tool citations

### Schema Issues
If `schema_lint` fails:
1. Run `conda run -n nf-core nf-core pipelines schema build`
2. Fix any parameter definition issues
3. Ensure JSONSchema Draft 7 compliance

### Configuration Issues
If `nextflow_config` fails, check:
- `manifest.name` matches pipeline name
- `manifest.version` follows semantic versioning
- Required params are defined with defaults
- Profile definitions are complete

## Output Interpretation

- **PASSED**: Test passed (shown with `--show-passed`)
- **WARNED**: Advisory issue, should fix but not blocking
- **FAILED**: Critical issue, must fix before release

Test names are clickable hyperlinks (Ctrl/Cmd+click) that open documentation for that specific test.
