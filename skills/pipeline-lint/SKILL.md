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

Validate pipelines against nf-core community guidelines **AND** Nextflow strict syntax requirements.

## Two Types of Linting

### 1. Nextflow Strict Syntax (`nextflow lint`)

**⚠️ CRITICAL: Required by Q2 2026 for all nf-core pipelines**

Validates Nextflow code against strict syntax rules (zero tolerance for deprecated patterns).

```bash
# Check strict syntax violations
nextflow lint .
nextflow lint main.nf
nextflow lint workflows/

# Enable strict parser (Nextflow v25.x)
export NXF_SYNTAX_PARSER=v2
nextflow lint .
```

**What it checks:**
- Removed syntax (errors): for/while loops, switch statements, import statements, etc.
- Deprecated patterns (warnings): `Channel.` uppercase, implicit closure params, `shell:` blocks
- Future incompatibilities that will break in Nextflow v26.04.0+

**Current ecosystem status** (as of Feb 2026):
- **3,320 errors** across 131 nf-core pipelines
- Only **22.9% of pipelines** are error-free
- **Deadline: Q2 2026** - all pipelines must pass

### 2. nf-core Community Guidelines (`nf-core pipelines lint`)

Validates against nf-core standards (template compliance, documentation, CI, etc.).

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

### Complete Linting Workflow

1. **Run Nextflow Strict Syntax Lint First**:
   ```bash
   nextflow lint .
   ```
   - Fix all **errors** (strict syntax violations)
   - Address **warnings** (deprecated patterns)
   - These are CRITICAL for Q2 2026 deadline

2. **Run nf-core Community Lint**:
   ```bash
   conda run -n nf-core nf-core pipelines lint
   ```
   - Categorize: PASSED, WARNED, FAILED
   - Address FAILED tests first, then WARNED

3. **Apply Automatic Fixes**:
   - `nf-core pipelines lint --fix` (requires clean git)
   - Manual fixes for strict syntax violations

4. **Verify**:
   ```bash
   nextflow lint .                                    # Must be zero errors
   conda run -n nf-core nf-core pipelines lint       # All tests passed
   ```

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

### nf-core pipelines lint

- **PASSED**: Test passed (shown with `--show-passed`)
- **WARNED**: Advisory issue, should fix but not blocking
- **FAILED**: Critical issue, must fix before release

Test names are clickable hyperlinks (Ctrl/Cmd+click) that open documentation for that specific test.

### nextflow lint

- **Parse Errors**: Code cannot be parsed - fundamental syntax problems
- **Errors**: Strict syntax violations - will break in Nextflow v26.04.0+
- **Warnings**: Deprecated patterns - should fix soon, will become errors later

## Common Strict Syntax Fixes

### Replace for/while loops with functional operators

```nextflow
// ❌ ERROR - for loops not allowed
def results = []
for (item in list) {
    results.add(process(item))
}

// ✅ FIX - use .collect()
def results = list.collect { item ->
    process(item)
}
```

### Remove import statements

```nextflow
// ❌ ERROR - imports not allowed
import groovy.json.JsonSlurper

def json = new JsonSlurper().parse(file)

// ✅ FIX - use fully qualified names
def json = new groovy.json.JsonSlurper().parse(file)
```

### Fix Channel. to channel.

```nextflow
// ❌ WARNING - uppercase Channel deprecated
ch = Channel.of(1, 2, 3)

// ✅ FIX
ch = channel.of(1, 2, 3)
```

### Use explicit closure parameters

```nextflow
// ❌ WARNING - implicit 'it' parameter
ch.map { it * 2 }

// ✅ FIX
ch.map { v -> v * 2 }
```

### Fix env declarations in processes

```nextflow
// ❌ ERROR - unquoted env
process example {
    env FOO

    script:
    """
    echo $FOO
    """
}

// ✅ FIX - quote env variables
process example {
    env 'FOO'

    script:
    """
    echo $FOO
    """
}
```

### Replace switch statements

```nextflow
// ❌ ERROR - switch not allowed
switch (type) {
    case 'A':
        handleA()
        break
    default:
        handleDefault()
}

// ✅ FIX - use if-else
if (type == 'A') {
    handleA()
} else {
    handleDefault()
}
```

### Move classes to lib/ directory

```nextflow
// ❌ ERROR - top-level class declarations not allowed
class MyHelper {
    static String format(String s) { s.toUpperCase() }
}

// ✅ FIX - move to lib/MyHelper.groovy
// Then use: MyHelper.format('test')
```

### Fix addParams in include statements

```nextflow
// ❌ ERROR - addParams deprecated
include { MODULE } from './modules/tool' addParams(options: [...])

// ✅ FIX - pass as workflow inputs
include { MODULE } from './modules/tool'

workflow {
    MODULE(input_ch, options: [...])
}
```
