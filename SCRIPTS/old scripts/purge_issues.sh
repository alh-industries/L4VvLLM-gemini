#!/bin/bash
# ===================================================================================
#
# DANGER: THIS SCRIPT DELETES REPOSITORY ISSUES AND CUSTOM LABELS.
# Version: 3.0 `while read' loop, avoids rate limiting
#
# ===================================================================================

# --- Delete All Issues ---

echo
echo "WARNING: This will permanently delete ALL issues from the repository."
read -p "Do you want to proceed with deleting all issues? (y/n) " -n 1 -r
echo # Move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Fetching and deleting all issues..."

 # Command to delete all issues safely
gh issue list --state all --limit 9999 --json number -q '.[].number' | while read -r issue_number; do
  echo "Deleting issue #${issue_number}..."
  gh issue delete "$issue_number" --yes
  sleep 1
done

echo "All issues have been purged."