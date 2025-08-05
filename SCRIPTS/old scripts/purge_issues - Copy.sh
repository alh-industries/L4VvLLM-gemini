#!/bin/bash
# ===================================================================================
#
# DANGER: THIS SCRIPT DELETES REPOSITORY ISSUES AND CUSTOM LABELS.
# Version: 2.3 - Fixed xargs warning and issue deletion bug
# 2.4 - added LABELS purge (commented out) 
# This script must be run manually from your local machine.
#
# ===================================================================================

# --- Delete All Issues ---

echo
echo "WARNING: This will permanently delete ALL issues from the repository."
read -p "Do you want to proceed with deleting all issues? (y/n) " -n 1 -r
echo # Move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Fetching and deleting all issues..."

  # CORRECTED COMMAND:
  # 1. Removed the redundant '-n 1' flag to fix the xargs warning.
  # 2. Changed the jq query from '.[].name' to '.[].number' to correctly fetch the issue numbers.

  gh issue list --state all --limit 9999 --json number -q '.[].number' | xargs -I {} gh issue delete {} --yes

  echo "All issues have been purged."

# uncomment below to delete all Labels, including defaults:

# echo "WARNING: This will permanently delete ALL Labels from the repository."
# read -p "Do you want to proceed with deleting all issues? (y/n) " -n 1 -r
# echo # Move to a new line
# if [[ $REPLY =~ ^[Yy]$ ]]; then
# echo "Deleting Labels" 
# gh label list --limit 1000 --json name -q '.[].name' | while read -r label; do gh label delete "$label" --yes
# echo "All Labels purged."


fi

echo
echo "Purge script finished."
echo "Press [Enter] to close the terminal."
read