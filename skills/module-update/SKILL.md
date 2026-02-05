---
name: module-update
description: Update installed nf-core modules to newer versions. Use when updating dependencies, syncing with upstream changes, checking for updates, or maintaining module versions.
argument-hint: "[module-name|--all]"
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Glob
---

# Update nf-core Modules

Update modules installed from nf-core/modules to their latest versions.

## Quick Commands

```bash
# Check for updates (preview only)
conda run -n nf-core nf-core modules update --preview

# Update specific module
conda run -n nf-core nf-core modules update fastqc

# Update all modules
conda run -n nf-core nf-core modules update --all

# Update to specific commit
conda run -n nf-core nf-core modules update fastqc --sha abc123

# Force update (even if up-to-date)
conda run -n nf-core nf-core modules update fastqc --force

# Save diff instead of applying
conda run -n nf-core nf-core modules update fastqc --save-diff updates.patch
```

## Process

1. **Preview Updates**: Run with `--preview` to see available updates
2. **Review Changes**: Check what will change
3. **Update Modules**: Apply updates
4. **Handle Patches**: Re-apply any local patches
5. **Test**: Run tests to verify functionality
6. **Commit**: Commit updated modules

## Update Modes

### Preview Mode
```bash
conda run -n nf-core nf-core modules update --preview
```
Shows what would be updated without making changes.

### Interactive Update
```bash
conda run -n nf-core nf-core modules update fastqc --prompt
```
Prompts for version selection.

### Silent Update
```bash
conda run -n nf-core nf-core modules update --all
```
Updates all modules to latest without prompts.

## Handling Local Modifications

If you've modified installed modules:

### Option 1: Create Patch Before Update
```bash
# Create patch from modifications
conda run -n nf-core nf-core modules patch fastqc

# Update module (patch auto-applied)
conda run -n nf-core nf-core modules update fastqc
```

### Option 2: Save Diff
```bash
# Save update as diff file
conda run -n nf-core nf-core modules update fastqc --save-diff fastqc.patch

# Review and apply manually
git apply fastqc.patch
```

### Option 3: Force Update
```bash
# Overwrite local changes
conda run -n nf-core nf-core modules update fastqc --force

# Re-apply custom changes manually
```

## Module Versioning

Modules are tracked in `modules.json`:
```json
{
  "repos": {
    "https://github.com/nf-core/modules.git": {
      "modules": {
        "nf-core": {
          "fastqc": {
            "branch": "master",
            "git_sha": "abc123def456...",
            "installed_by": ["modules"]
          }
        }
      }
    }
  }
}
```

## Checking Installed Versions

```bash
# List all installed modules with versions
conda run -n nf-core nf-core modules list local

# Get info about specific module
conda run -n nf-core nf-core modules info fastqc
```

## Update Workflow

### Single Module Update
```bash
# 1. Check current version
conda run -n nf-core nf-core modules info fastqc

# 2. Preview update
conda run -n nf-core nf-core modules update fastqc --preview

# 3. Apply update
conda run -n nf-core nf-core modules update fastqc

# 4. Test
conda run -n nf-core nf-test test modules/nf-core/fastqc/

# 5. Commit
git add modules/nf-core/fastqc/ modules.json
git commit -m "Update fastqc module"
```

### Bulk Update
```bash
# 1. Preview all updates
conda run -n nf-core nf-core modules update --all --preview

# 2. Apply all updates
conda run -n nf-core nf-core modules update --all

# 3. Run all tests
conda run -n nf-core nf-test test

# 4. Commit
git add modules/ modules.json
git commit -m "Update all nf-core modules"
```

## Troubleshooting

### Merge Conflicts
If patch application fails:
```bash
# Remove patch
rm modules/nf-core/tool/.nf-core-patch.yaml

# Force update
conda run -n nf-core nf-core modules update tool --force

# Re-apply changes manually and create new patch
conda run -n nf-core nf-core modules patch tool
```

### Module Not Found
```bash
# Refresh module list
conda run -n nf-core nf-core modules list remote --update
```

### Version Pinning
To pin a module to specific version:
```bash
# Install specific version
conda run -n nf-core nf-core modules install fastqc --sha specific_commit

# Don't update this module
# (manually exclude from --all updates)
```

## Best Practices

1. **Update regularly**: Keep modules current for bug fixes and features
2. **Test after updates**: Run nf-test suite
3. **Review changelogs**: Check nf-core/modules for breaking changes
4. **Use patches**: Don't modify modules directly; use patch system
5. **Commit separately**: Update modules in dedicated commits
