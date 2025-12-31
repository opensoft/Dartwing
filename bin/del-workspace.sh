#!/bin/bash
# Intelligent script resolver - checks workBenches first, then falls back to project structure

# Script we're looking for
SCRIPT_NAME="delete-frappe-workspace.sh"
BENCH_TYPE="frappeBench"

# Try workBenches location first (preferred)
WORKBENCH_SCRIPT="/home/brett/projects/workBenches/devBenches/${BENCH_TYPE}/scripts/${SCRIPT_NAME}"

if [ -f "$WORKBENCH_SCRIPT" ]; then
    exec "$WORKBENCH_SCRIPT" "$@"
fi

# Fall back to finding it in the current project structure
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Search for the script in common locations
for potential_path in \
    "${PROJECT_ROOT}/frappe/scripts/${SCRIPT_NAME}" \
    "${PROJECT_ROOT}/scripts/${SCRIPT_NAME}" \
    "${PROJECT_ROOT}/*/scripts/${SCRIPT_NAME}"; do
    if [ -f "$potential_path" ]; then
        exec "$potential_path" "$@"
    fi
done

echo "Error: Could not find ${SCRIPT_NAME}" >&2
echo "Searched in:" >&2
echo "  - ${WORKBENCH_SCRIPT}" >&2
echo "  - ${PROJECT_ROOT}/frappe/scripts/${SCRIPT_NAME}" >&2
exit 1
