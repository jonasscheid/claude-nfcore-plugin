---
name: open-pr
description: Open a pull request on an nf-core pipeline repository. Use when the user wants to create a PR, open a pull request, or submit changes for review.
---

# Open nf-core Pull Request

## Process

### Step 1: Gather Context

1. Read the PR template from `.github/PULL_REQUEST_TEMPLATE.md` in the project root.
2. Identify the current branch and ensure it is NOT `dev` or `master`/`main`.
3. Determine the base branch: default to `dev` (nf-core convention). Only use another branch if the user explicitly requests it.
4. Check if the branch has been pushed to the remote.
5. Review all commits on this branch vs the base branch (`git log` and `git diff <base>...HEAD`) to understand the full scope of changes.

### Step 2: Prepare PR Details

1. Derive a **PR title** from the changes (or use one if the user already provided it).
2. Write a **short, concise description** summarizing the work done based on the commits and diff. Keep it brief — if the changes are small, the description should be small. No need to inflate minor work into a big description.

### Step 3: Create the PR

1. Push the branch to the remote if not already pushed.
2. Construct the PR body:
   - Start with `## Description\n\n<user-provided description>`
   - Then append the **exact, unmodified** contents of `.github/PULL_REQUEST_TEMPLATE.md` (with only the leading HTML comment block removed)
3. Create the PR using `gh pr create`.
4. Return the PR URL to the user.

## Critical Rules

- **Use the PR template exactly as-is.** The only allowed modification is removing the HTML comment block at the top. Do NOT check/uncheck boxes, delete checklist items, reword items, or restructure the template in any way.
- **Always target `dev` branch** unless the user explicitly says otherwise.
- **Never include "Generated with Claude Code" or any Claude citation** in the PR body.
- **Auto-generate the description** from the commits/diff. Keep it short and concise — proportional to the size of the changes.
