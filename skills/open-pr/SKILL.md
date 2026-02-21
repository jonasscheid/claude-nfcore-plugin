---
name: open-pr
description: Open a pull request on an nf-core pipeline repository using the standard nf-core PR template. Use when the user wants to create a PR, open a pull request, submit changes for review, or push their branch and create a PR. Verifies relevant checklist items from the PR template before opening.
---

# Open nf-core Pull Request

Create a pull request on an nf-core pipeline repository using the standard nf-core PR template with checklist verification.

## PR Template

The following is the exact nf-core PR template. It MUST be used as the body of the PR (with the HTML comment removed and a `## Description` section prepended for the user's description):

```markdown
<!--
# nf-core/mhcquant pull request

Many thanks for contributing to nf-core/mhcquant!

Please fill in the appropriate checklist below (delete whatever is not relevant).
These are the most common things requested on pull requests (PRs).

Remember that PRs should be made against the dev branch, unless you're preparing a pipeline release.

Learn more about contributing: [CONTRIBUTING.md](https://github.com/nf-core/mhcquant/tree/master/.github/CONTRIBUTING.md)
-->

## PR checklist

- [ ] This comment contains a description of changes (with reason).
- [ ] If you've fixed a bug or added code that should be tested, add tests!
- [ ] If you've added a new tool - have you followed the pipeline conventions in the [contribution docs](https://github.com/nf-core/mhcquant/tree/master/.github/CONTRIBUTING.md)
- [ ] If necessary, also make a PR on the nf-core/mhcquant _branch_ on the [nf-core/test-datasets](https://github.com/nf-core/test-datasets) repository.
- [ ] Make sure your code lints (`nf-core pipelines lint`).
- [ ] Ensure the test suite passes (`nextflow run . -profile test,docker --outdir <OUTDIR>`).
- [ ] Check for unexpected warnings in debug mode (`nextflow run . -profile debug,test,docker --outdir <OUTDIR>`).
- [ ] Usage Documentation in `docs/usage.md` is updated.
- [ ] Output Documentation in `docs/output.md` is updated.
- [ ] `CHANGELOG.md` is updated.
- [ ] `README.md` is updated (including new tool citations and authors/contributors).
```

## Process

### Step 1: Gather Context

1. **Detect the pipeline name** from `manifest.name` in `nextflow.config` or the git remote URL. Replace `mhcquant` in the template with the actual pipeline name.
2. **Identify the current branch** and ensure it is NOT `dev` or `master`/`main`.
3. **Determine the base branch**: Default to `dev` (nf-core convention). Only use `master` if the user explicitly says this is a release PR.
4. **Check remote tracking**: Determine if the branch has been pushed to the remote.
5. **Review all commits** on this branch vs the base branch (`git log` and `git diff <base>...HEAD`) to understand the full scope of changes.

### Step 2: Ask User for PR Description

Ask the user to provide:
- A **description of changes** (with reason) — this is the first checklist item and is mandatory
- A **PR title** (if not already provided)

### Step 3: Evaluate PR Checklist

Go through each checklist item and determine which are relevant to this PR based on the actual changes. For each relevant item, verify whether it has been satisfied.

**Checklist evaluation:**

1. **"This comment contains a description of changes (with reason)"** — Always relevant. Satisfied when user provides description.

2. **"If you've fixed a bug or added code that should be tested, add tests!"** — Relevant if PR includes new code or bug fixes. Check for corresponding `.nf.test` files.

3. **"If you've added a new tool - have you followed the pipeline conventions"** — Relevant only if new modules/tools were added in `modules/`.

4. **"If necessary, also make a PR on the nf-core/mhcquant branch on the nf-core/test-datasets repository"** — Relevant only if test data needs were changed.

5. **"Make sure your code lints"** — Always relevant. Run `nextflow lint .` and `conda run -n nf-core nf-core pipelines lint` to verify. Report results.

6. **"Ensure the test suite passes"** — Always relevant. Remind user to verify, check CI status.

7. **"Check for unexpected warnings in debug mode"** — Relevant for significant changes. Remind user.

8. **"Usage Documentation in docs/usage.md is updated"** — Relevant if new parameters, inputs, or usage patterns were added.

9. **"Output Documentation in docs/output.md is updated"** — Relevant if output files changed.

10. **"CHANGELOG.md is updated"** — Always relevant. Check if `CHANGELOG.md` was modified in this branch.

11. **"README.md is updated (including new tool citations and authors/contributors)"** — Relevant if new tools were added or significant features changed.

### Step 4: Report Checklist Status

Present the checklist to the user showing:
- Which items are relevant vs not relevant to this PR
- Which relevant items pass verification
- Which relevant items need attention (with explanation)

Ask the user to confirm they want to proceed, or if they want to address any items first.

### Step 5: Create the PR

1. **Push the branch** to the remote if not already pushed:
   ```bash
   git push -u origin <branch-name>
   ```

2. **Construct the PR body** using the exact template structure:
   - Add a `## Description` section at the top with the user's description
   - Include the `## PR checklist` section with all items
   - Mark items as `[x]` if verified, `[ ]` if not yet verified or not relevant
   - Delete checklist items that are clearly not relevant (as the template instructs: "delete whatever is not relevant")

3. **Create the PR**:
   ```bash
   gh pr create --base dev --title "<title>" --body "$(cat <<'EOF'
   ## Description

   <user-provided description>

   ## PR checklist

   - [x] This comment contains a description of changes (with reason).
   - [ ] If you've fixed a bug or added code that should be tested, add tests!
   ...remaining relevant items...
   EOF
   )"
   ```

4. **Return the PR URL** to the user.

## Important Rules

- **Always target `dev` branch** unless the user explicitly says otherwise
- **Use the exact template** — do not paraphrase or restructure the checklist items
- **Replace pipeline name** in the template (e.g., `mhcquant`) with the actual pipeline name from the repo
- **Never include "Generated with Claude Code" or any Claude citation** in the PR body
- **Always ask user for description** — never auto-generate it
- **Don't block on warnings** — inform the user and let them decide
- **Run linting checks** and report results rather than silently skipping
