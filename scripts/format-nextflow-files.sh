#!/bin/bash
#
# Auto-format .nf files after they are written or edited
# This script runs as a PostToolUse hook on Edit|Write
#

# Read input from stdin (JSON with tool info)
INPUT=$(cat)

# Extract the file path from the tool input
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only process .nf files
if [[ ! "$FILE" =~ \.nf$ ]]; then
    exit 0
fi

if [ ! -f "$FILE" ]; then
    exit 0
fi

if ! command -v nextflow &> /dev/null; then
    exit 0
fi

nextflow lint -format -sort-declarations -spaces 4 -harshil-alignment "$FILE" 2>/dev/null

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":\"Auto-formatted $FILE\"}}"

exit 0
