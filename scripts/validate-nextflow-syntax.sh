#!/bin/bash
#
# Validate Nextflow syntax after file edits
# This script runs as a PostToolUse hook for .nf and .config files
#

# Read input from stdin (JSON with tool info)
INPUT=$(cat)

# Extract file path from the tool result
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit if no file path
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Only process .nf and .config files
if [[ ! "$FILE_PATH" =~ \.(nf|config)$ ]]; then
    exit 0
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

WARNINGS=""
ERRORS=""

# Check for Channel. instead of channel. (nf-core convention)
if grep -qE '\bChannel\.' "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}Use lowercase 'channel.' instead of 'Channel.' per nf-core conventions. "
fi

# Check for deprecated DSL1 syntax
if grep -qE '^\s*process\s+\w+\s*{' "$FILE_PATH" 2>/dev/null; then
    # Check if it's missing proper DSL2 structure
    if ! grep -qE 'input:|output:|script:|shell:|exec:' "$FILE_PATH" 2>/dev/null; then
        WARNINGS="${WARNINGS}Process may be using deprecated DSL1 syntax. "
    fi
fi

# Check for params without proper quoting in strings
if grep -qE '"\$params\.' "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}Consider using string interpolation carefully with params. "
fi

# Check for hardcoded container versions with :latest
if grep -qE 'container.*:latest' "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}Avoid using ':latest' container tags - use specific versions. "
fi

# Try to validate Nextflow syntax if nextflow is available
if command -v nextflow &> /dev/null; then
    # Run nextflow lint on the file to check for strict syntax violations
    # This is CRITICAL for Q2 2026 deadline - all nf-core pipelines must pass
    LINT_OUTPUT=$(nextflow lint "$FILE_PATH" 2>&1 || true)

    # Check for errors in the lint output
    if echo "$LINT_OUTPUT" | grep -qE '(error|ERROR)'; then
        # Extract error messages
        ERROR_MSGS=$(echo "$LINT_OUTPUT" | grep -E '(error|ERROR)' | head -3 | tr '\n' ' ')
        ERRORS="${ERRORS}Nextflow strict syntax violations detected: ${ERROR_MSGS}. Run 'nextflow lint ${FILE_PATH}' for details. Q2 2026 deadline: all pipelines must pass nextflow lint. "
    fi

    # Check for warnings (deprecated patterns)
    if echo "$LINT_OUTPUT" | grep -qE '(warning|WARNING)'; then
        WARN_COUNT=$(echo "$LINT_OUTPUT" | grep -cE '(warning|WARNING)' || echo "0")
        if [ "$WARN_COUNT" -gt 0 ]; then
            WARNINGS="${WARNINGS}Nextflow lint found ${WARN_COUNT} warning(s) - deprecated patterns that will become errors in future versions. Run 'nextflow lint ${FILE_PATH}' for details. "
        fi
    fi
fi

# Check for overly broad output glob patterns (e.g., path("*.ext") instead of path("${prefix}.ext"))
if grep -qE '^\s*output:' "$FILE_PATH" 2>/dev/null; then
    # Look for path("*.something") patterns but exclude versions.yml
    BROAD_GLOBS=$(grep -nE 'path\(\s*"?\*\.[a-zA-Z]' "$FILE_PATH" 2>/dev/null | grep -v 'versions\.yml' || true)
    if [ -n "$BROAD_GLOBS" ]; then
        WARNINGS="${WARNINGS}Broad wildcard output pattern detected (e.g., path(\"*.ext\")). Use prefix-based patterns like path(\"\${prefix}.ext\") to avoid capturing staged input files as outputs. This is especially costly on cloud storage (AWS S3). "
    fi
fi

# Check for common Groovy/Nextflow syntax issues
# Unclosed braces (simple check)
OPEN_BRACES=$(grep -o '{' "$FILE_PATH" 2>/dev/null | wc -l)
CLOSE_BRACES=$(grep -o '}' "$FILE_PATH" 2>/dev/null | wc -l)
if [ "$OPEN_BRACES" -ne "$CLOSE_BRACES" ]; then
    WARNINGS="${WARNINGS}Possible mismatched braces (found $OPEN_BRACES open, $CLOSE_BRACES close). "
fi

# Output warnings if any
if [ -n "$WARNINGS" ]; then
    # Format as JSON output for Claude Code
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":\"${WARNINGS}\"}}"
fi

exit 0
