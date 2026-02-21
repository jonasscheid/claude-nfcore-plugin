# nf-core Claude Code Plugin

A comprehensive Claude Code plugin for nf-core Nextflow pipeline development. Includes skills for pipeline creation, module management, linting, testing, and release preparation following nf-core best practices.

## Features

### Skills (16)

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
| `open-pr` | Open PRs using nf-core PR template with checklist verification |
| `open-issue` | Open issues using nf-core bug report or feature request templates |
| `metro-map` | Generate subway-style metro maps for pipeline visualization |

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
/nf-core:pipeline-lint          # Lint your pipeline
/nf-core:module-install fastqc  # Install a module
/nf-core:best-practices         # View reference guide
/nf-core:nf-test                # Run tests
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) CLI
- Python environment with nf-core tools, nf-test, and Nextflow

### Installation Options

**Option 1: Conda/Mamba (Recommended)**

All-in-one installation using the provided environment file:

```bash
# Using mamba (faster)
mamba env create -f environment.yml
mamba activate nf-core

# Or using conda
conda env create -f environment.yml
conda activate nf-core

# Verify installation
nf-core --version
nf-test --version
nextflow -version
```

**Option 2: Pixi (Modern alternative)**

[Pixi](https://pixi.sh) offers faster dependency resolution and better reproducibility:

```bash
# Install pixi
curl -fsSL https://pixi.sh/install.sh | bash

# Install dependencies
pixi install

# Use pixi shell or run commands directly
pixi shell
# OR
pixi run nf-core --version
```

**Option 3: pip/uv (Python-only)**

For users preferring Python package managers:

```bash
# Using pip
pip install -r requirements.txt

# Using uv (faster pip alternative)
uv pip install -r requirements.txt

# Note: You still need to install nf-test and Nextflow separately
# nf-test: curl -fsSL https://get.nf-test.com | bash
# Nextflow: curl -s https://get.nextflow.io | bash
```

**Option 4: Manual (Quick setup)**

```bash
mamba create -n nf-core nf-core nf-test nextflow
```

### Package Manager Notes

- **The plugin's skills default to `conda run -n nf-core`** for command execution
- If using **pixi**, commands will work directly in the pixi shell (`pixi shell`)
- If using **pip/uv**, you'll need to ensure `nf-core`, `nf-test`, and `nextflow` are in your PATH
- **Recommended**: Use mamba/conda or pixi for simplest setup with all dependencies

## nf-core Conventions Enforced

This plugin helps enforce nf-core best practices and Nextflow strict syntax requirements:

### Nextflow Strict Syntax (Q2 2026 Deadline)
- **Automatic validation** of `.nf` and `.config` files using `nextflow lint`
- **Error detection** for removed syntax (for/while loops, switch, imports, etc.)
- **Warning detection** for deprecated patterns (`Channel.`, implicit closures, `shell:`)
- **Comprehensive guidance** on migrating to strict syntax compliance

### nf-core Best Practices
- Use lowercase `channel.` instead of `Channel.`
- Parameter names in `snake_case`
- Boolean parameters with negative naming (`skip_X` not `run_X`)
- Prefix-based output patterns (`path("${prefix}.ext")` not `path("*.ext")`)
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
└── skills/                  # 16 user-invocable skills
```

## License

MIT

## Links

- [nf-core](https://nf-co.re)
- [nf-core/tools](https://github.com/nf-core/tools)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
