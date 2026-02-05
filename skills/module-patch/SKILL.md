---
name: module-patch
description: Create patches for local modifications to nf-core modules. Use when customizing modules while maintaining update compatibility, adding pipeline-specific changes, or preserving modifications across module updates.
argument-hint: "[module-name]"
allowed-tools:
  - Bash(conda run -n nf-core *)
  - Read
  - Glob
  - Grep
---

# nf-core Module Patching

Create and manage patches for local modifications to nf-core modules, preserving changes across updates.

## Quick Commands

```bash
# Create patch for modified module
conda run -n nf-core nf-core modules patch fastqc

# List modules with patches
conda run -n nf-core nf-core modules list local --show-patches

# Remove patch (revert to original)
conda run -n nf-core nf-core modules patch fastqc --remove
```

## Why Use Patches?

- **Maintain customizations**: Keep pipeline-specific changes
- **Survive updates**: Patches auto-apply when updating modules
- **Pass linting**: Linter accepts patched modules
- **Track changes**: Git-friendly modification tracking

## Process

1. **Install Module**: Get the base module from nf-core/modules
2. **Modify Files**: Make your customizations
3. **Create Patch**: Run patch command to capture changes
4. **Test**: Verify module works as expected
5. **Update Module**: Patches auto-apply on updates

## Creating a Patch

### Step 1: Install Module
```bash
conda run -n nf-core nf-core modules install fastqc
```

### Step 2: Modify Module
Edit `modules/nf-core/fastqc/main.nf`:
```nextflow
process FASTQC {
    // ... existing code ...

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // Add custom argument
    def custom_arg = params.fastqc_custom ? '--custom-flag' : ''
    """
    fastqc \\
        $args \\
        $custom_arg \\
        --threads $task.cpus \\
        $reads
    """
}
```

### Step 3: Create Patch
```bash
conda run -n nf-core nf-core modules patch fastqc
```

This creates `modules/nf-core/fastqc/.nf-core-patch.yaml`

## Patch File Structure

```yaml
# .nf-core-patch.yaml
changes:
  - filename: main.nf
    diff: |
      --- a/modules/nf-core/fastqc/main.nf
      +++ b/modules/nf-core/fastqc/main.nf
      @@ -25,6 +25,8 @@ process FASTQC {
           script:
           def args = task.ext.args ?: ''
           def prefix = task.ext.prefix ?: "${meta.id}"
      +    // Custom modification
      +    def custom_arg = params.fastqc_custom ? '--custom-flag' : ''
```

## Updating Patched Modules

```bash
# Update module - patch automatically applied
conda run -n nf-core nf-core modules update fastqc
```

If patch fails to apply cleanly:
1. Conflicts are reported
2. Review changes manually
3. Recreate patch if needed

## Common Patch Scenarios

### Adding Custom Arguments
```nextflow
// Add pipeline-specific parameters
def custom = params.tool_extra ?: ''
```

### Modifying Resource Labels
```nextflow
// Change from process_low to process_medium
label 'process_medium'
```

### Adding Conditional Logic
```nextflow
// Skip under certain conditions
when:
task.ext.when == null || task.ext.when && !params.skip_tool
```

### Custom Output Naming
```nextflow
// Use custom prefix pattern
def prefix = task.ext.prefix ?: "${meta.id}_${meta.condition}"
```

## Managing Multiple Patches

```bash
# List all patched modules
conda run -n nf-core nf-core modules list local

# Modules with patches show [patched] indicator
# nf-core:
#   fastqc [patched]
#   multiqc
#   samtools/sort [patched]
```

## Removing Patches

```bash
# Remove patch and revert to original
conda run -n nf-core nf-core modules patch fastqc --remove

# This removes .nf-core-patch.yaml and reverts changes
```

## Best Practices

### DO
- Keep patches minimal and focused
- Document why patch is needed (comments)
- Test patched modules thoroughly
- Recreate patches after major module updates

### DON'T
- Patch for things that should be ext.args
- Make extensive changes (consider local module)
- Forget to recreate patch after manual edits

## When to Use Local Module Instead

Consider creating a local module if:
- Changes are extensive (>50% of code)
- Tool usage is very different from nf-core version
- Multiple pipelines need different versions
- Upstream module doesn't fit your use case

```bash
# Create local module instead
mkdir -p modules/local/mytool
cp modules/nf-core/tool/main.nf modules/local/mytool/
# Edit freely without patches
```

## Troubleshooting

### Patch Won't Apply
```bash
# Check patch status
git diff modules/nf-core/fastqc/

# Remove patch and recreate
conda run -n nf-core nf-core modules patch fastqc --remove
# Make changes again
conda run -n nf-core nf-core modules patch fastqc
```

### Lint Fails on Patched Module
Ensure `.nf-core-patch.yaml` exists and patch is properly formatted.

### Lost Changes After Update
If patch didn't apply, changes are in conflict. Check git status and manually resolve.
