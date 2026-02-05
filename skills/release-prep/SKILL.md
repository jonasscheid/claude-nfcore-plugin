---
name: release-prep
description: Prepare an nf-core pipeline for release. Use before releasing a new version, when checking release readiness, completing the release checklist, or finalizing documentation for a release.
argument-hint: "[version]"
disable-model-invocation: true
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# nf-core Pipeline Release Preparation

Comprehensive checklist and process for preparing an nf-core pipeline release.

## Quick Commands

```bash
# Run full lint suite
conda run -n nf-core nf-core pipelines lint

# Run all tests
conda run -n nf-core nf-test test

# Check versions
grep -r "version" nextflow.config | head -20

# Validate schema
conda run -n nf-core nf-core pipelines schema lint
```

## Release Checklist

### 1. Version Number
- [ ] Update `manifest.version` in `nextflow.config`
- [ ] Follow semantic versioning: MAJOR.MINOR.PATCH
- [ ] Version matches across all files

```nextflow
// nextflow.config
manifest {
    version = '2.1.0'
}
```

### 2. CHANGELOG.md
- [ ] Add new version section with date
- [ ] List all changes since last release
- [ ] Categorize: Added, Changed, Fixed, Deprecated, Removed
- [ ] Credit contributors

```markdown
## [2.1.0] - 2024-01-15

### Added
- New feature X (#123)

### Changed
- Updated module Y to v2.0 (#124)

### Fixed
- Bug in process Z (#125)

### Contributors
@contributor1, @contributor2
```

### 3. Documentation
- [ ] `docs/usage.md` - Accurate usage instructions
- [ ] `docs/output.md` - All outputs documented
- [ ] `README.md` - Up to date
- [ ] `nextflow_schema.json` - All params documented

### 4. Code Quality
- [ ] All lint tests pass: `nf-core pipelines lint`
- [ ] All nf-tests pass: `nf-test test`
- [ ] CI/CD tests pass on GitHub
- [ ] No TODO comments in code
- [ ] Code is readable and maintainable

### 5. Parameters
- [ ] All use snake_case naming
- [ ] Boolean params use negative naming (skip_X not run_X)
- [ ] Defaults are sensible
- [ ] Required params clearly marked
- [ ] Schema validates correctly

### 6. Modules & Subworkflows
- [ ] All modules updated to latest versions
- [ ] Local modules properly documented
- [ ] Module tests pass

### 7. Containers
- [ ] All tools have versioned containers
- [ ] No `:latest` tags
- [ ] Both Docker and Singularity work

### 8. Citations
- [ ] `CITATIONS.md` lists all tools
- [ ] Proper citation format
- [ ] DOIs where available

### 9. Final Checks
- [ ] Test profile works: `nextflow run . -profile test,docker`
- [ ] Full test passes: `nextflow run . -profile test_full,docker`
- [ ] AWS tests pass (if applicable)

## Pre-Release Process

### Step 1: Update Dev Branch
```bash
git checkout dev
git pull origin dev
```

### Step 2: Run Full Lint
```bash
conda run -n nf-core nf-core pipelines lint
# Fix any issues
```

### Step 3: Run All Tests
```bash
conda run -n nf-core nf-test test --profile docker
# Ensure all pass
```

### Step 4: Update Version
```bash
# Edit nextflow.config
# manifest.version = 'X.Y.Z'
```

### Step 5: Update CHANGELOG
```bash
# Add version section with date
# List all changes
```

### Step 6: Final Commit to Dev
```bash
git add -A
git commit -m "Prepare release X.Y.Z"
git push origin dev
```

### Step 7: Create Release PR
```bash
# Create PR from dev to master
gh pr create --base master --head dev --title "Release X.Y.Z"
```

### Step 8: Review & Merge
- Wait for CI tests
- Get two approvals
- Merge to master

### Step 9: Create GitHub Release
```bash
# Tag the release
git checkout master
git pull
git tag -a X.Y.Z -m "Release X.Y.Z"
git push origin X.Y.Z

# Create release on GitHub with notes from CHANGELOG
```

## Version Numbering Guide

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Breaking changes | MAJOR | 1.0.0 → 2.0.0 |
| New features | MINOR | 1.0.0 → 1.1.0 |
| Bug fixes | PATCH | 1.0.0 → 1.0.1 |

## Common Release Issues

### Lint Failures
```bash
# Run with fix flag
conda run -n nf-core nf-core pipelines lint --fix
```

### Version Mismatch
Check these files match:
- `nextflow.config` (manifest.version)
- `CHANGELOG.md` (latest version)

### Missing Citations
```bash
# Find tools without citations
grep -r "process " modules/ | grep -v "CITATIONS"
```

### Schema Out of Sync
```bash
# Rebuild schema
conda run -n nf-core nf-core pipelines schema build
```

## Post-Release

1. **Announce**: Post on nf-core Slack
2. **DOI**: Register new version on Zenodo
3. **Update docs**: Refresh website documentation
4. **Merge back**: Sync master changes to dev

```bash
git checkout dev
git merge master
git push origin dev
```
