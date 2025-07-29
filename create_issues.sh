#!/usr/bin/env bash

# Execute all gh issue commands listed in Planner2ghlist.txt
# Usage: ./create_issues.sh [file]
# Requires: GitHub CLI authenticated with repo scope.

set -o pipefail
FILE=${1:-Planner2ghlist.txt}

if ! command -v gh >/dev/null 2>&1; then
    echo "Error: GitHub CLI 'gh' not found in PATH" >&2
    exit 1
fi

while IFS= read -r CMD; do
    CMD="${CMD//$'\r'/}" # strip CR if present
    [[ -z "$CMD" ]] && continue
    [[ "$CMD" =~ ^# ]] && continue
    echo "Running: $CMD"
    bash -c "$CMD"
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
        echo "Command failed with status $STATUS: $CMD" >&2
    fi
    echo
done < "$FILE"

