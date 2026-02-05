---
name: pipeline-sync
description: Sync your pipeline with nf-core template updates. Use when updating to newer template versions, resolving template conflicts, or maintaining template compatibility.
argument-hint: "[--from-branch] [--pull-request]"
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Bash(git *)
  - Read
  - Glob
  - Grep
---

# nf-core Pipeline Template Sync

Synchronize your pipeline with updates to the nf-core template.

## Quick Commands

```bash
# Check if sync is needed
conda run -n nf-core nf-core pipelines sync --show

# Run sync (creates PR)
conda run -n nf-core nf-core pipelines sync

# Sync without creating PR
conda run -n nf-core nf-core pipelines sync --no-pull-request

# Sync specific directory
conda run -n nf-core nf-core pipelines sync --dir /path/to/pipeline

# Sync from specific branch
conda run -n nf-core nf-core pipelines sync --from-branch TEMPLATE
```

## How Template Sync Works

1. **TEMPLATE Branch**: Contains vanilla nf-core template with your pipeline's metadata
2. **Sync Process**: Updates TEMPLATE branch with latest template version
3. **PR Creation**: Opens pull request from TEMPLATE to dev
4. **Manual Merge**: You review and merge, resolving conflicts

## Git Branch Structure

```
master ─────────────────────────► (releases only)
         ╲
          ╲  merge PR
dev ───────●─────●─────●─────────► (active development)
           │     ▲
           │     │ merge sync PR
           │     │
TEMPLATE ──●─────●───────────────► (template updates)
```

## Process

1. **Ensure Clean Working Directory**:
   ```bash
   git status
   git stash  # if needed
   ```

2. **Checkout Dev Branch**:
   ```bash
   git checkout dev
   git pull origin dev
   ```

3. **Run Sync**:
   ```bash
   conda run -n nf-core nf-core pipelines sync
   ```

4. **Review PR**: Check the automatically created PR

5. **Resolve Conflicts**: If there are merge conflicts:
   ```bash
   git checkout nf-core-template-merge-<version>
   git merge dev
   # Resolve conflicts
   git add .
   git commit
   git push
   ```

6. **Merge PR**: After resolving conflicts and CI passes

## Resolving Merge Conflicts

Common conflict areas:

### nextflow.config
Keep your custom params, but update boilerplate:
```nextflow
<<<<<<< HEAD
params.my_custom_param = 'value'  // Keep this
=======
// New template structure       // Take structural changes
>>>>>>> TEMPLATE
```

### .github/workflows/ci.yml
Usually take template version, add back custom jobs

### README.md
Merge carefully, keeping custom content and new template sections

### lib/WorkflowMain.groovy
Usually take template version unless heavily customized

## Fixing Broken TEMPLATE Branch

If TEMPLATE branch has issues:

```bash
# Delete local TEMPLATE branch
git branch -D TEMPLATE

# Fetch fresh from remote
git fetch origin TEMPLATE:TEMPLATE

# Or recreate from scratch
conda run -n nf-core nf-core pipelines sync --make-template-branch
```

## Manual Sync (Alternative)

If automatic sync fails:

1. **Create fresh template**:
   ```bash
   conda run -n nf-core nf-core pipelines create --template-yaml .nf-core.yml --outdir /tmp/fresh
   ```

2. **Compare and merge manually**:
   ```bash
   diff -r /tmp/fresh/nf-core-mypipeline .
   ```

3. **Apply changes selectively**

## Sync Configuration

In `.nf-core.yml`:

```yaml
# Template version (auto-updated by sync)
nf_core_version: "3.0.0"

# Pipeline metadata for template recreation
org: nf-core
name: mypipeline

# Features to skip
skip:
  - igenomes
  - slackreport
```

## Common Issues

### "TEMPLATE branch not found"
```bash
# Create TEMPLATE branch retrospectively
conda run -n nf-core nf-core pipelines sync --make-template-branch
```

### "Uncommitted changes"
```bash
git stash
conda run -n nf-core nf-core pipelines sync
git stash pop
```

### Merge conflicts overwhelming
Consider syncing more frequently (each nf-core/tools release)

## Automated Sync

nf-core pipelines receive automatic sync PRs when new template versions release:
- Bot creates PR from TEMPLATE to dev
- CI runs automatically
- Maintainers review and merge

For non-nf-core pipelines, run sync manually after each nf-core/tools update.
