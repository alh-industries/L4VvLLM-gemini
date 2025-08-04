#!/bin/bash
# ===================================================================================
#
# DANGER: THIS SCRIPT DELETES REPOSITORY ISSUES AND CUSTOM LABELS.
# Version: 2.2.1 - Condensed to one loop
# 2.2.1 - add 'read' cmd (last line)
# This script must be run manually from your local machine.
#
# ===================================================================================

# --- Delete Custom Labels ---
# echo "This script can delete all non-default labels from the repository."
# read -p "Do you want to proceed with deleting custom labels? (y/n) " -n 1 -r
# echo # Move to a new line
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#   echo "Finding and deleting custom labels..."
  # This one-liner gets all labels, filters out the default ones, and deletes the rest.
#   gh label list --json name -q '.[].name' | grep -v -x -F -f <(printf "%s\n" "bug" "documentation" # "duplicate" "enhancement" "good first issue" "help wanted" "invalid" "question" "wontfix") | xargs -n 1 -I {} gh label delete "{}" --yes
#   echo "Custom labels purged."
# fi

# --- Delete All Issues ---
echo
echo "WARNING: This will permanently delete ALL issues from the repository."
read -p "Do you want to proceed with deleting all issues? (y/n) " -n 1 -r
echo # Move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Fetching and deleting all issues..."
  gh issue list --state all --limit 9999 --json number -q '.[].name' | xargs -n 1 -I {} gh issue delete {} --yes

# gh label list --json name -q '.[].name' | grep -v -x -F -f <(printf "%s\n" "bug" "documentation" "duplicate" "enhancement" "good first issue" "help wanted" "invalid" "question" "wontfix") | xargs -n 1 -I {} gh label delete "{}" --yes # delete 'grep' to erase default labels too
# echo "Custom labels purged."

  echo "All issues have been purged."
fi

echo
echo "Purge script finished."
echo "Press [Enter] to close the terminal."
read