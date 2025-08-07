# ===================================================================================
# SCRIPT C: MANAGE GITHUB PROJECT (v1.0)
# ===================================================================================
#!/bin/bash
# --- Configuration ---
DATA_FILE_PATH_C="TSV_HERE/"
PROJECT_NUMBER_C="8"

# --- Script Initialization ---
DATA_FILE_C=$(find "$DATA_FILE_PATH_C" -maxdepth 1 -name "*.tsv" -print -quit)
[ -z "$DATA_FILE_C" ] && { echo "Error: No .tsv file found in '$DATA_FILE_PATH_C' for Script C"; exit 1; }
DELIMITER_C=$'\t'
HEADERS_C=$(head -n 1 "$DATA_FILE_C")

# --- Dynamic Column Indexing ---
get_col_index_C() {
  echo "$HEADERS_C" | tr "$DELIMITER_C" '\n' | grep -n -i "$1" | cut -d: -f1
}
ISSUE_TITLE_COL_C=$(get_col_index_C "ISSUE_TITLE")

# ===================================================================================
# PHASE 1 (SCRIPT C): CREATE PROJECT FIELDS AND OPTIONS
# ===================================================================================
echo "--- Script C, Phase 1: Creating project fields... ---"
for i in $(seq 1 $(echo "$HEADERS_C" | tr "$DELIMITER_C" '\n' | wc -l)); do
  header_C=$(echo "$HEADERS_C" | cut -f$i)
  if [[ "$header_C" == *PROJECT_FIELD_* ]]; then
    field_name_C=$(echo "$header_C" | sed -e 's/.*PROJECT_FIELD_//' -e 's/:.*//')
    data_type_C=$(echo "$header_C" | sed 's/.*://')

    echo "Ensuring project field '$field_name_C' exists..."
    gh project field-create "$PROJECT_NUMBER_C" --owner "@me" --name "$field_name_C" --data-type "$(echo "$data_type_C" | tr '[:upper:]' '[:lower:]')" || true

    if [[ "$data_type_C" == "SINGLE_SELECT" ]]; then
      cut -f$i "$DATA_FILE_C" | tail -n +2 | sort -u | grep . | while read -r option; do
        echo "  - Adding option: $option to field $field_name_C"
        gh project field-create "$PROJECT_NUMBER_C" --owner "@me" --name "$field_name_C" --single-select-option "$option" || true
      done
    fi
  fi
done
echo "Project field creation complete."
# ===================================================================================

# ===================================================================================
# PHASE 2 (SCRIPT C): ADD ISSUES AND POPULATE FIELDS
# ===================================================================================
echo "--- Script C, Phase 2: Adding issues to project... ---"
tail -n +2 "$DATA_FILE_C" | while IFS="$DELIMITER_C" read -r -a values; do
  issue_title_C="${values[$((ISSUE_TITLE_COL_C-1))]}"
  [ -z "$issue_title_C" ] && continue

  issue_url_C=$(gh issue list --search "in:title \"$issue_title_C\"" --state all --limit 1 --json url -q '.[0].url' || echo "")
  [ -z "$issue_url_C" ] && { echo "Warning: Could not find issue '$issue_title_C'. Skipping."; continue; }

  item_id_C=$(gh project item-add "$PROJECT_NUMBER_C" --owner "@me" --issue "$issue_url_C" --format json | jq -r '.id' || echo "")

  if [ -z "$item_id_C" ] || [ "$item_id_C" == "null" ]; then
    item_id_C=$(gh project item-list "$PROJECT_NUMBER_C" --owner "@me" --query "$issue_title_C" --format json | jq -r --arg title "$issue_title_C" '.items[] | select(.content.title == $title) | .id' | head -n 1)
    [ -z "$item_id_C" ] && { echo "Error: Could not find project item for '$issue_title_C'."; continue; }
  fi

  for i in "${!values[@]}"; do
    header_C=$(echo "$HEADERS_C" | cut -f$((i+1)))
    if [[ "$header_C" == *PROJECT_FIELD_* ]] && [ -n "${values[$i]}" ]; then
      field_name_C=$(echo "$header_C" | sed -e 's/.*PROJECT_FIELD_//' -e 's/:.*//')
      field_value_C="${values[$i]}"
      echo "  - Setting field '$field_name_C' to '$field_value_C' for issue '$issue_title_C'"
      gh project item-edit --id "$item_id_C" --field-name "$field_name_C" --text "$field_value_C" || echo "  - Warning: Could not set field '$field_name_C'."
    fi
  done
  sleep 1
done
echo "Script C finished."
# ===================================================================================
# END OF SCRIPT C
# ===================================================================================
