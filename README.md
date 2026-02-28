# nf-core Claude Code Plugin

A Claude Code plugin for nf-core Nextflow pipeline development. Skills mirror the `nf-core` CLI structure for intuitive use. Agents handle autonomous tasks like lint fixing, module creation, and code review.

## Features

### Skills (4)

| Skill | Description | Maps to CLI |
|-------|-------------|-------------|
| `pipelines` | Create, lint, schema, sync, and release pipelines | `nf-core pipelines <action>` |
| `modules` | Create, install, update, patch, and lint modules/subworkflows | `nf-core modules/subworkflows <action>` |
| `nf-test` | Run and manage nf-test tests | `nf-test` |
| `best-practices` | Quick reference for nf-core conventions | — |

### Agents (6)

| Agent | Description |
|-------|-------------|
| `pipeline-explorer` | Explore and analyze pipeline structure (read-only) |
| `pipeline-architect` | Plan pipeline migrations and refactoring |
| `lint-fixer` | Autonomously fix lint errors |
| `nf-core-reviewer` | Review code for nf-core compliance |
| `test-writer` | Create nf-test tests |
| `module-creator` | Create new modules from scratch |

### Hooks

- **PostToolUse**: Validates Nextflow syntax after editing `.nf` and `.config` files
- **PreToolUse**: Checks nf-core conventions before writing files

## Installation

### Option 1: Clone and use directly

```bash
git clone https://github.com/jonasscheid/claude-nfcore-plugin.git
claude --plugin-dir ./claude-nfcore-plugin
```

### Option 2: Add to Claude Code settings

Add to your `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "/absolute/path/to/claude-nfcore-plugin": true
  }
}
```

## Usage

Once installed, use skills with the `/nf-core:` prefix:

```
/nf-core:pipelines lint          # Lint your pipeline
/nf-core:pipelines create        # Create a new pipeline
/nf-core:modules install fastqc  # Install a module
/nf-core:modules create bwa/mem  # Create a new module
/nf-core:nf-test                 # Run tests
/nf-core:best-practices          # View conventions reference
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) CLI
- Python environment with nf-core tools, nf-test, and Nextflow

### Installation Options

**Conda/Mamba (Recommended)**

```bash
mamba create -n nf-core nf-core nf-test nextflow -c conda-forge -c bioconda
```

**pip**

```bash
pip install nf-core
# nf-test and Nextflow must be installed separately:
# nf-test: curl -fsSL https://get.nf-test.com | bash
# Nextflow: curl -s https://get.nextflow.io | bash
```

**uv**

```bash
uv pip install nf-core
# nf-test and Nextflow must be installed separately
```

### First-Use Setup

On first skill invocation, you'll be asked which package manager you use. Your preference is stored in `nf-core.local.md` within the plugin directory and used for all subsequent commands.

## nf-core Conventions Enforced

### Nextflow Strict Syntax (Q2 2026 Deadline)
- Automatic validation of `.nf` and `.config` files via hooks
- Error detection for removed syntax (for/while loops, switch, imports, etc.)
- Warning detection for deprecated patterns (`Channel.`, implicit closures, `shell:`)

### nf-core Best Practices
- Lowercase `channel.` instead of `Channel.`
- Parameter names in `snake_case`
- Boolean parameters with negative naming (`skip_X` not `run_X`)
- Prefix-based output patterns (`path("${prefix}.ext")` not `path("*.ext")`)
- PRs target `dev` branch for nf-core repos

## Directory Structure

```
.
├── .claude-plugin/
│   └── plugin.json       # Plugin manifest
├── agents/               # 6 autonomous agents
├── hooks/
│   └── hooks.json        # Validation hooks
├── scripts/              # Hook scripts
├── shared/               # Reference docs read by skills and agents
│   ├── conventions.md    # nf-core conventions, strict syntax, naming
│   ├── module-template.md # Module structure and templates
│   └── test-patterns.md  # nf-test patterns and assertions
└── skills/               # 4 user-invocable skills
    ├── best-practices/
    ├── modules/
    ├── nf-test/
    └── pipelines/
```

## License

MIT

## Links

- [nf-core](https://nf-co.re)
- [nf-core/tools](https://github.com/nf-core/tools)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
