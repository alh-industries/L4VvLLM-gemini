#!/bin/bash
# ===================================================================================
#
# NAME: purge_ALL.sh
# DANGER: THIS IS A NON-INTERACTIVE SCRIPT. WHEN RUN VIA A GITHUB ACTION, IT
#         IMMEDIATELY DELETES ALL REPOSITORY ISSUES AND LABELS.
# Version: 5.0
#
# ===================================================================================

echo "--- Purging All Issues ---"
# This loop safely deletes issues one by one to avoid rate limits.
gh issue list --state all --limit 9999 --json number -q '.[].number' | while read -r issue_number; do
  echo "Deleting issue #${issue_number}..."
  gh issue delete "$issue_number" --yes
  sleep 1
done
echo "All issues have been purged."

echo
echo "--- Purging All Labels ---"
# This loop safely deletes labels one by one to avoid rate limits.
gh label list --limit 1000 --json name -q '.[].name' | while read -r label_name; do
  echo "Deleting label '${label_name}'..."
  gh label delete "$label_name" --yes
  sleep 1
done
echo "All labels have been purged."

echo
echo "Purge script finished."