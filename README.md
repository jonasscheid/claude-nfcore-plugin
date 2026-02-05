# nf-core Claude Code Plugin

A comprehensive Claude Code plugin for nf-core Nextflow pipeline development. Includes skills for pipeline creation, module management, linting, testing, and release preparation following nf-core best practices.

## Features

### Skills (13)

| Skill | Description |
|-------|-------------|
| `pipeline-create` | Create new nf-core pipelines from template |
| `pipeline-lint` | Lint pipelines and auto-fix issues |
| `pipeline-schema` | Manage nextflow_schema.json |
| `pipeline-sync` | Sync with nf-core template updates |
| `module-install` | Install modules from nf-core/modules |
| `module-create` | Create new nf-core modules |
| `module-update` | Update installed modules |
| `module-patch` | Create patches for module modifications |
| `subworkflow-manage` | Manage subworkflows |
| `nf-test` | Run and manage nf-test tests |
| `release-prep` | Prepare pipeline for release |
| `samplesheet-create` | Create and validate samplesheets |
| `best-practices` | Comprehensive nf-core reference guide |

### Agents (5)

| Agent | Description |
|-------|-------------|
| `pipeline-explorer` | Explore and analyze pipeline structure |
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
claude --plugin-dir /path/to/claude-nfcore-plugin
```

### Option 2: Add to Claude Code settings

Add to your `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "/path/to/claude-nfcore-plugin": true
  }
}
```

## Usage

Once installed, use skills with the `/nf-core:` prefix:

```
/nf-core:pipeline-lint          # Lint your pipeline
/nf-core:module-install fastqc  # Install a module
/nf-core:best-practices         # View reference guide
/nf-core:nf-test                # Run tests
```

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- Conda environment `nf-core` with nf-core tools installed:
  ```bash
  mamba create -n nf-core nf-core
  ```
- Nextflow installed for syntax validation hooks

## nf-core Conventions Enforced

This plugin helps enforce nf-core best practices:

- Use lowercase `channel.` instead of `Channel.`
- Parameter names in `snake_case`
- Boolean parameters with negative naming (`skip_X` not `run_X`)
- All nf-core commands run via `conda run -n nf-core`
- PRs target `dev` branch for nf-core repos

## Directory Structure

```
.
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── agents/                  # 5 autonomous agents
├── hooks/
│   └── hooks.json           # Validation hooks
├── scripts/                 # Hook scripts
└── skills/                  # 13 user-invocable skills
```

## License

MIT

## Links

- [nf-core](https://nf-co.re)
- [nf-core/tools](https://github.com/nf-core/tools)
- [Claude Code](https://claude.ai/claude-code)
