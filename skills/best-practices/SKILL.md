---
name: best-practices
description: Quick reference for nf-core conventions that differ from standard Nextflow — strict syntax rules, naming conventions, output patterns. Use when asking about conventions, coding style, or how to structure nf-core code correctly.
user-invocable: true
---

# nf-core Best Practices

Quick reference for nf-core conventions. For detailed pipeline/module workflows, use `/nf-core:pipelines` or `/nf-core:modules`.

Read `${CLAUDE_PLUGIN_ROOT}/shared/conventions.md` for the full conventions reference including package manager setup.

---

## Nextflow Strict Syntax (CRITICAL — Q2 2026)

All nf-core pipelines must pass `nextflow lint` by Q2 2026. Run strict syntax lint **before** nf-core community lint.

```bash
<cmd> nextflow lint .         # FIRST — strict syntax
<cmd> nf-core pipelines lint  # SECOND — community guidelines
```

Replace `<cmd>` with your package manager prefix — see `${CLAUDE_PLUGIN_ROOT}/nf-core.local.md`.

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
| `final x = 1` / `String s = 'hi'` | `def x = 1` / `def s: String = 'hi'` (v25.10+) |

### Deprecated Syntax (Warnings — Future Errors)

| Deprecated | Use Instead |
|------------|-------------|
| `Channel.of(...)` | `channel.of(...)` (lowercase) |
| `ch.map { it * 2 }` | `ch.map { v -> v * 2 }` (explicit params) |
| `shell:` section | `script:` section |

### Preserving Complex Groovy Code

- **lib/ directory**: Full Groovy support for helper classes (temporary solution)
- **Plugins**: Recommended for reusable complex logic

---

## Output Glob Patterns

Always use prefix-based output patterns. Broad wildcards capture staged input files.

```nextflow
// CORRECT
tuple val(meta), path("${prefix}.bam"), emit: bam

// INCORRECT — captures staged inputs too
tuple val(meta), path("*.bam"), emit: bam
```

**Rule**: `${prefix}.ext` in output, never `*.ext`.

---

## Parameter Naming

- **snake_case**: `input_file`, `min_read_length` (not camelCase)
- **Boolean negatives**: `skip_fastqc`, `skip_trimming` (not `run_fastqc`, `enable_trimming`)

| Standard Param | Description |
|---------------|-------------|
| `input` | Primary input samplesheet |
| `outdir` | Output directory |
| `fasta` | Reference FASTA |
| `genome` | iGenomes genome key |
| `max_cpus` / `max_memory` / `max_time` | Resource limits |

---

## Channel Naming

- **Prefix with `ch_`**: `ch_input`, `ch_reads`, `ch_versions`
- **Lowercase `channel.`**: `channel.fromPath()`, `channel.empty()` (never `Channel.`)
- **Descriptive**: `ch_filtered_reads`, `ch_sorted_bam`

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

## Conventions Summary

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

## Migration Roadmap

| Feature | Enforce? | Required | Notes |
|---------|----------|----------|-------|
| Strict syntax | **ENFORCE** | Q2 2026 | CRITICAL deadline |
| Version topics | **ENFORCE** | Mid-2026 | Already allowed |
| Workflow output | Don't enforce | Q4 2026 | Coming soon |
| Static types & records | Don't enforce | Q2 2027 | Gradual rollout |
| New process syntax | Don't enforce | Q2 2027 | Gradual rollout |

---

## Resources

- [Nextflow Strict Syntax](https://nextflow.io/docs/latest/strict-syntax.html)
- [nf-core Roadmap](https://nf-co.re/blog/2025/nextflow_syntax_nf-core_roadmap)
- [nf-core Strict Syntax Health](https://github.com/nf-core/strict-syntax-health)
