#!/bin/bash
# ===================================================================================
#
# SCRIPT A: CREATE ISSUES AND LABELS (v6.0)
#
# - Uses dynamic substring matching to find column indexes, making it
#   resilient to header name changes and column reordering.
# - Phase 1: Reads the file to find and create all unique labels.
# - Phase 2: Reads the file again to create/update issues with those labels.
#
# ===================================================================================

# --- Configuration ---
DATA_FILE_PATH_A="TSV_HERE/"

# --- Script Initialization ---
DATA_FILE_A=$(find "$DATA_FILE_PATH_A" -maxdepth 1 -name "*.tsv" -print -quit)
[ -z "$DATA_FILE_A" ] && { echo "Error: No .tsv file found in '$DATA_FILE_PATH_A' for Script A"; exit 1; }
DELIMITER_A=$'\t'
HEADERS_A=$(head -n 1 "$DATA_FILE_A")

# --- Dynamic Column Indexing ---
get_col_index_A() {
  echo "$HEADERS_A" | tr "$DELIMITER_A" '\n' | grep -n -i "$1" | cut -d: -f1
}

LOCAL_ID_COL_A=$(get_col_index_A "LOCAL_ID")
ISSUE_TITLE_COL_A=$(get_col_index_A "ISSUE_TITLE")
ISSUE_BODY_COL_A=$(get_col_index_A "ISSUE_BODY")

# ===================================================================================
# PHASE 1 (SCRIPT A): PRE-PROCESS AND CREATE ALL LABELS
# ===================================================================================
echo "--- Script A, Phase 1: Creating all required labels... ---"
declare -A all_labels_A
tail -n +2 "$DATA_FILE_A" | while IFS="$DELIMITER_A" read -r -a values; do
  local_id_A="${values[$((LOCAL_ID_COL_A-1))]}"
  [ -n "$local_id_A" ] && all_labels_A["ID:$local_id_A"]=1
  for i in "${!values[@]}"; do
    header_A=$(echo "$HEADERS_A" | cut -f$((i+1)))
    if [[ "$header_A" == *ISSUE_LABEL* ]]; then
      [ -n "${values[$i]}" ] && all_labels_A["${values[$i]}"]=1
    fi
  done
done

for label in "${!all_labels_A[@]}"; do
  gh label create "$label" --color "$(openssl rand -hex 3)" --description "Auto-generated" || true
done
echo "Label creation phase complete."
# ===================================================================================

# ===================================================================================
# PHASE 2 (SCRIPT A): PROCESS ROWS AND CREATE ISSUES
# ===================================================================================
echo "--- Script A, Phase 2: Creating and updating issues... ---"
tail -n +2 "$DATA_FILE_A" | while IFS="$DELIMITER_A" read -r -a values; do
  issue_title_A="${values[$((ISSUE_TITLE_COL_A-1))]}"
  issue_body_A=$(echo "${values[$((ISSUE_BODY_COL_A-1))]}" | sed 's/;/\\n/g')
  local_id_A="${values[$((LOCAL_ID_COL_A-1))]}"

  issue_labels_A=()
  [ -n "$local_id_A" ] && issue_labels_A+=("ID:$local_id_A")
  for i in "${!values[@]}"; do
    header_A=$(echo "$HEADERS_A" | cut -f$((i+1)))
    if [[ "$header_A" == *ISSUE_LABEL* ]]; then
      [ -n "${values[$i]}" ] && issue_labels_A+=("${values[$i]}")
    fi
  done

  label_args_A=()
  for label in "${issue_labels_A[@]}"; do
    label_args_A+=("--label" "$label")
  done

  existing_issue_url_A=$(gh issue list --search "in:title \"$issue_title_A\"" --state all --limit 1 --json url -q '.[0].url' || echo "")
  if [ -n "$existing_issue_url_A" ]; then
    echo "ID:$local_id_A - Updating issue: '$issue_title_A'"
    gh issue edit "$existing_issue_url_A" --body "$issue_body_A"
    for label in "${issue_labels_A[@]}"; do
      gh issue edit "$existing_issue_url_A" --add-label "$label" || true
    done
  else
    echo "ID:$local_id_A - Creating issue: '$issue_title_A'"
    gh issue create --title "$issue_title_A" --body "$issue_body_A" "${label_args_A[@]}"
  fi
  sleep 1
done
echo "Script A finished."
# ===================================================================================
# END OF SCRIPT A
# ===================================================================================