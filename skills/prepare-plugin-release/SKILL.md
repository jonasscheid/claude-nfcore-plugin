---
name: prepare-plugin-release
description: Prepare a new release of the nf-core Claude Code plugin — bumps version, updates CHANGELOG with merged PRs since the last release. Use before releasing a new plugin version.
argument-hint: "[version]"
allowed-tools:
  - Bash(gh *)
  - Bash(git *)
  - Bash(jq *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# Prepare Plugin Release

Prepares a new version of the nf-core Claude Code plugin by bumping the version and generating a CHANGELOG entry from merged PRs.

**Important:** This skill targets the `dev` or a feature branch. The `main` branch is only updated via a dev → main PR.

---

## Workflow

### Step 1: Determine versions

1. Read the current version from `.claude-plugin/plugin.json`
2. If the user provided a target version as argument, use that. Otherwise, ask what version to release.
3. Validate it follows semver (MAJOR.MINOR.PATCH)

### Step 2: Identify the last release boundary

Find the commit or tag that marks the previous release:

```bash
# Check for git tags first
git tag --list 'v*' --sort=-version:refname | head -1
# Or check for the last version bump commit
git log --oneline --grep="release" --grep="version" --all-match | head -1
```

If no tags exist, use the first commit as the boundary (all PRs are new).

### Step 3: Fetch merged PRs since last release

Use the GitHub CLI to get all merged PRs to `main` since the last release:

```bash
# If a tag exists for the previous version:
gh pr list --repo jonasscheid/claude-nfcore-plugin --state merged --base main --search "merged:>YYYY-MM-DD" --json number,title,labels,mergedAt,author --limit 100

# If no tag exists, get all merged PRs:
gh pr list --repo jonasscheid/claude-nfcore-plugin --state merged --base main --json number,title,labels,mergedAt,author --limit 100
```

### Step 4: Categorize PRs into CHANGELOG sections

Map each PR into one of these sections based on its title and labels:

| Section | Trigger keywords/labels |
|---------|------------------------|
| `Added` | "add", "new", "feature", "create", label:enhancement |
| `Changed` | "update", "change", "refactor", "improve", "rename", label:refactor |
| `Fixed` | "fix", "bug", "correct", "resolve", label:bug |
| `Deprecated` | "deprecate", "remove", label:deprecated |
| `Dependencies` | "bump", "dependency", "upgrade", label:dependencies |

If unclear, default to `Changed`.

### Step 5: Format CHANGELOG entry

Use the nf-core CHANGELOG convention:

```markdown
## X.Y.Z - YYYY-MM-DD

### `Added`

- [PR #123](https://github.com/jonasscheid/claude-nfcore-plugin/pull/123) - Short description of what was added

### `Changed`

- [PR #456](https://github.com/jonasscheid/claude-nfcore-plugin/pull/456) - Short description of what changed

### `Fixed`

- [PR #789](https://github.com/jonasscheid/claude-nfcore-plugin/pull/789) - Short description of what was fixed
```

Rules for entry descriptions:
- Use the PR title as the base, but clean it up to be concise
- Start with a verb (Add, Update, Fix, Remove, etc.)
- Keep each entry to one line
- Only include sections that have entries (omit empty sections)
- Link every entry to its PR

### Step 6: Update files

1. **`CHANGELOG.md`**: Insert the new version entry below the header block (above any existing version entries). Keep the `dev` entry at the top if there is one, or replace it with the release entry.
2. **`.claude-plugin/plugin.json`**: Update the `"version"` field to the new version.

### Step 7: Show the user what changed

Display a summary:
- The new version number
- Number of PRs included
- The generated CHANGELOG entry
- Remind the user to review, commit to dev/feature branch, and open a PR to main

---

## CHANGELOG Format Reference

The CHANGELOG follows the nf-core convention:

```markdown
# nf-core Claude Code Plugin: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## X.Y.Z - YYYY-MM-DD

### `Added`

- [PR #N](https://github.com/jonasscheid/claude-nfcore-plugin/pull/N) - Description

### `Changed`

- [PR #N](https://github.com/jonasscheid/claude-nfcore-plugin/pull/N) - Description

### `Fixed`

- [PR #N](https://github.com/jonasscheid/claude-nfcore-plugin/pull/N) - Description
```

Section order: `Added` → `Changed` → `Fixed` → `Deprecated` → `Dependencies`
