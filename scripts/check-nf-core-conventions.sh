#!/bin/bash
#
# Check nf-core conventions before writing files
# This script runs as a PreToolUse hook for Write operations on .nf and .config files
#

# Read input from stdin (JSON with tool info)
INPUT=$(cat)

# Extract file path and content from the tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')

# Exit if no content to check
if [ -z "$CONTENT" ]; then
    exit 0
fi

# Only process .nf and .config files
if [[ ! "$FILE_PATH" =~ \.(nf|config)$ ]]; then
    exit 0
fi

REMINDERS=""

# Check for Channel. instead of channel.
if echo "$CONTENT" | grep -qE '\bChannel\.'; then
    REMINDERS="${REMINDERS}nf-core convention uses lowercase 'channel.' instead of 'Channel.'. "
fi

# Check for camelCase parameter names (should be snake_case)
if echo "$CONTENT" | grep -qE 'params\.[a-z]+[A-Z]'; then
    REMINDERS="${REMINDERS}Parameter names should use snake_case (e.g., 'params.input_file' not 'params.inputFile'). "
fi

# Check for positive boolean naming (should be negative)
if echo "$CONTENT" | grep -qE 'params\.(run_|enable_|do_)[a-z_]+'; then
    REMINDERS="${REMINDERS}Boolean parameters should use negative naming (e.g., 'skip_qc' instead of 'run_qc'). "
fi

# Check for missing versions.yml in process
if echo "$CONTENT" | grep -qE '^\s*process\s+' && ! echo "$CONTENT" | grep -qE 'versions\.yml'; then
    if echo "$CONTENT" | grep -qE '^\s*output:'; then
        REMINDERS="${REMINDERS}Process should emit versions.yml for version tracking. "
    fi
fi

# Check for :latest container tags
if echo "$CONTENT" | grep -qE 'container.*:latest'; then
    REMINDERS="${REMINDERS}Use specific container version tags instead of ':latest'. "
fi

# Check for missing stub block in process
if echo "$CONTENT" | grep -qE '^\s*process\s+' && ! echo "$CONTENT" | grep -qE '^\s*stub:'; then
    if echo "$CONTENT" | grep -qE '^\s*script:'; then
        REMINDERS="${REMINDERS}Consider adding a stub: block for testing with stub runs. "
    fi
fi

# Check for hardcoded paths
if echo "$CONTENT" | grep -qE "'/home/|'/Users/|'/data/"; then
    REMINDERS="${REMINDERS}Avoid hardcoded absolute paths - use params instead. "
fi

# Check for process label
if echo "$CONTENT" | grep -qE '^\s*process\s+' && ! echo "$CONTENT" | grep -qE "label\s+'process_"; then
    REMINDERS="${REMINDERS}Process should have a resource label (e.g., label 'process_medium'). "
fi

# Check for overly broad output glob patterns (e.g., path("*.ext") instead of path("${prefix}.ext"))
if echo "$CONTENT" | grep -qE '^\s*output:'; then
    if echo "$CONTENT" | grep -E 'path\(\s*"?\*\.[a-zA-Z]' | grep -vqE 'versions\.yml'; then
        REMINDERS="${REMINDERS}Output uses broad wildcard pattern (e.g., path(\"*.ext\")). Use prefix-based patterns like path(\"\${prefix}.ext\") to avoid capturing staged input files as outputs, which causes unnecessary file copying (especially costly on cloud storage). "
    fi
fi

# Output reminders if any
if [ -n "$REMINDERS" ]; then
    # Format as JSON output for Claude Code
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"additionalContext\":\"${REMINDERS}\"}}"
fi

exit 0
