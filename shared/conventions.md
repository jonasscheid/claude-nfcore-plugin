# nf-core Conventions Reference

Single source of truth for nf-core conventions. Read by all skills and agents.

## Setup — Package Manager

Read `${CLAUDE_PLUGIN_ROOT}/nf-core.local.md` for the user's package manager preference.

If the file doesn't exist, ask the user which package manager they use:

| Package Manager | nf-core commands | nf-test commands | nextflow commands |
|-----------------|-----------------|------------------|-------------------|
| conda/mamba (Recommended) | `conda run -n <env> nf-core ...` | `conda run -n <env> nf-test ...` | `conda run -n <env> nextflow ...` |
| pip | `nf-core ...` | `nf-test ...` | `nextflow ...` |
| uv | `uv run nf-core ...` | `uv run nf-test ...` | `uv run nextflow ...` |

Store their choice in `${CLAUDE_PLUGIN_ROOT}/nf-core.local.md`:
```yaml
---
package-manager: conda
conda-env: nf-core
---
```

Use the corresponding command prefix (`<cmd_prefix>`) for all commands.

---

## nf-core Migration Roadmap

> Update this table as Nextflow and nf-core evolve. Last updated: Feb 2026.

| Feature | Enforce? | Allow in Linting | In Template | Required | Notes |
|---------|----------|-----------------|-------------|----------|-------|
| Strict syntax | **ENFORCE** | — | Q2 2026 | Q2 2026 | CRITICAL deadline. Run `nextflow lint .` |
| Version topics in modules | **ENFORCE** | Q4 2025 | Mid-2026 | Mid-2026 | Already allowed by linting |
| Workflow output | Don't enforce | — | Mid-2026 | Q4 2026 | Coming soon |
| Static types & records | Don't enforce | Mid-2026 | Q4 2026 | Q2 2027 | Gradual rollout |
| New process syntax | Don't enforce | Mid-2026 | Q4 2026 | Q2 2027 | Gradual rollout |

---

## Nextflow Strict Syntax (CRITICAL — Q2 2026)

All nf-core pipelines must pass `nextflow lint` by Q2 2026. Always run strict syntax lint **before** nf-core community lint.

```bash
<cmd_prefix> nextflow lint .         # FIRST — strict syntax
<cmd_prefix> nf-core pipelines lint  # SECOND — community guidelines
```

### Removed Syntax (Errors)

| Not Allowed | Use Instead |
|-------------|-------------|
| `import groovy.json.JsonSlurper` | `new groovy.json.JsonSlurper()` (fully qualified) |
| `class MyClass { }` | Move to `lib/` directory |
| `for (i in list) { }` | `.each()`, `.collect()`, `.find()` |
| `while (cond) { }` | `.each()` or recursion |
| `switch (x) { }` | if-else chains |
| `addParams(...)` | Pass as explicit workflow inputs |
| `env FOO` (unquoted) | `env 'FOO'` (always quote) |
| `[meta, *items]` (spread) | `[meta, items[0], items[1]]` (enumerate) |
| `final x = 1` | `def x = 1` |
| `String s = 'hi'` | `def s = 'hi'` or `def s: String = 'hi'` (v25.10+) |

### Deprecated Syntax (Warnings — Future Errors)

| Deprecated | Use Instead |
|------------|-------------|
| `Channel.of(...)` | `channel.of(...)` (lowercase) |
| `ch.map { it * 2 }` | `ch.map { v -> v * 2 }` (explicit params) |
| `shell:` section | `script:` section |

---

## Output Glob Patterns

Always use prefix-based output patterns. Broad wildcards capture staged input files as outputs, causing unnecessary copying (costly on cloud storage).

```nextflow
// CORRECT
output:
tuple val(meta), path("${prefix}.bam"), emit: bam

// INCORRECT — may capture input BAMs
output:
tuple val(meta), path("*.bam"), emit: bam
```

**Rule**: If the tool writes `${prefix}.ext`, declare `path("${prefix}.ext")`, not `path("*.ext")`.

---

## Parameter Naming

- **snake_case**: `input_file`, `min_read_length` (not camelCase)
- **Boolean negatives**: `skip_fastqc`, `skip_trimming` (not `run_fastqc`, `enable_trimming`)
- **Standard names**: `input`, `outdir`, `fasta`, `gtf`, `genome`, `max_cpus`, `max_memory`, `max_time`

---

## Channel Naming

- **Prefix with `ch_`**: `ch_input`, `ch_reads`, `ch_versions`
- **Lowercase `channel.`**: `channel.fromPath()`, `channel.empty()`, `channel.of()` (never `Channel.`)
- **Descriptive**: `ch_filtered_reads`, `ch_sorted_bam` (not `ch_data`, `ch_output`)

---

## Process Labels

| Label | CPUs | Memory | Time |
|-------|------|--------|------|
| `process_single` | 1 | 6.GB | 4.h |
| `process_low` | 2 | 12.GB | 4.h |
| `process_medium` | 6 | 36.GB | 8.h |
| `process_high` | 12 | 72.GB | 16.h |
| `process_long` | 2 | 12.GB | 20.h |
| `process_high_memory` | 10 | 200.GB | 12.h |

---

## Process Conventions

- **Names**: UPPERCASE (`TOOL_SUBTOOL`)
- **Tag**: `tag "$meta.id"`
- **`when` block**: `task.ext.when == null || task.ext.when`
- **`ext.args`**: `def args = task.ext.args ?: ''`
- **`prefix`**: `def prefix = task.ext.prefix ?: "${meta.id}"`
- **`versions.yml`**: Always emit as `path "versions.yml", emit: versions`
- **`stub` block**: Required for all processes
- **Version collection**: `ch_versions = ch_versions.mix(PROCESS.out.versions.first())`

---

## Quick-Reference Summary

| Aspect | Convention |
|--------|------------|
| Channel factory | `channel.` (lowercase) |
| Parameters | `snake_case` |
| Booleans | Negative form (`skip_X`) |
| Channel names | `ch_` prefix |
| Process names | `UPPERCASE` |
| Output patterns | `path("${prefix}.ext")` |
| Git PR target | `dev` branch |
| Lint order | `nextflow lint .` then `nf-core pipelines lint` |

---

## Resources

- [Nextflow Strict Syntax](https://nextflow.io/docs/latest/strict-syntax.html)
- [nf-core Roadmap](https://nf-co.re/blog/2025/nextflow_syntax_nf-core_roadmap)
- [nf-core Strict Syntax Health](https://github.com/nf-core/strict-syntax-health)
