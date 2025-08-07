# ===================================================================================
# SCRIPT B: CREATE SUB-ISSUES FROM BODY (v2.0)
# ===================================================================================
#!/bin/bash
# --- Configuration ---
DATA_FILE_PATH_B="TSV_HERE/"

# --- Script Initialization ---
DATA_FILE_B=$(find "$DATA_FILE_PATH_B" -maxdepth 1 -name "*.tsv" -print -quit)
[ -z "$DATA_FILE_B" ] && { echo "Error: No .tsv file found in '$DATA_FILE_PATH_B' for Script B"; exit 1; }
DELIMITER_B=$'\t'
HEADERS_B=$(head -n 1 "$DATA_FILE_B")

# --- Dynamic Column Indexing ---
get_col_index_B() {
  echo "$HEADERS_B" | tr "$DELIMITER_B" '\n' | grep -n -i "$1" | cut -d: -f1
}
ISSUE_TITLE_COL_B=$(get_col_index_B "ISSUE_TITLE")
ISSUE_BODY_COL_B=$(get_col_index_B "ISSUE_BODY")

# --- Processing ---
echo "--- Running Script B: Creating sub-issues... ---"
tail -n +2 "$DATA_FILE_B" | while IFS="$DELIMITER_B" read -r -a values; do
  parent_issue_title_B="${values[$((ISSUE_TITLE_COL_B-1))]}"
  issue_body_for_subtasks_B="${values[$((ISSUE_BODY_COL_B-1))]}"

  if [ -z "$parent_issue_title_B" ] || [ -z "$issue_body_for_subtasks_B" ]; then
    continue
  fi

  parent_issue_json_B=$(gh issue view "$parent_issue_title_B" --json number,body)
  parent_issue_number_B=$(echo "$parent_issue_json_B" | jq -r '.number')
  parent_issue_body_B=$(echo "$parent_issue_json_B" | jq -r '.body')

  if [ -z "$parent_issue_number_B" ] || [ "$parent_issue_number_B" == "null" ]; then
    echo "Warning: Could not find parent issue '$parent_issue_title_B'. Skipping."
    continue
  fi

  sub_issue_checklist_B=""
  while IFS=';' read -r -a subtasks; do
    for task in "${subtasks[@]}"; do
      trimmed_task_B=$(echo "$task" | xargs)
      if [ -n "$trimmed_task_B" ]; then
        sub_issue_checklist_B+="- [ ] $trimmed_task_B\n"
      fi
    done
  done <<< "$issue_body_for_subtasks_B"

  if [ -n "$sub_issue_checklist_B" ]; then
    new_body_B="$parent_issue_body_B\n\n### Sub-Tasks\n$sub_issue_checklist_B"
    echo "Adding sub-issue checklist to issue #$parent_issue_number_B"
    gh issue edit "$parent_issue_number_B" --body "$new_body_B"
  fi
  sleep 1
done
echo "Script B finished."
# ===================================================================================
# END OF SCRIPT B
# ===================================================================================
