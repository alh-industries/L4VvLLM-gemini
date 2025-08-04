#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# ===================================================================================
#
# GITHUB PROJECT AUTOMATION SCRIPT (v3.2 - Projects Disabled, Column # Option)
#
# - Handles existing labels and issues gracefully.
# - Provides detailed error logging.
# - Uses stricter column parsing to prevent errors.
# - Adds LOCAL_ID as a label to each issue.
# - Includes a new, optional way to define labels by column number.
#
# ===================================================================================


# ============================================
# PLEASE EDIT THESE VARIABLES
# ============================================
PROJECT_NUMBER="8"
DATA_FILE_PATH="TSV_HERE/"
# ============================================


# --- Script setup and initialization ---
DATA_FILE=$(find "$DATA_FILE_path" -maxdepth 1 \( -name "*.tsv" -o -name "*.csv" \) -print -quit)
ERROR_LOG_FILE="${DATA_FILE_PATH}errors.md"

if [ -z "$DATA_FILE" ]; then
  echo "Error: No .tsv or .csv file found in '$DATA_FILE_PATH'. Exiting."
  exit 1
fi

echo "Processing file: $DATA_FILE"
DELIMITER=$'\t'
if [[ "$DATA_FILE" == *.csv ]]; then
  DELIMITER=','
fi
rm -f "$ERROR_LOG_FILE"

# --- Main Processing Logic ---
IFS="$DELIMITER" read -r -a HEADERS < <(head -n 1 "$DATA_FILE")

process_row() {
  local row_content="$1"
  local local_id=""
  local issue_title=""
  local issue_body=""
  local issue_labels=()
  declare -A project_fields

  # --- OPTIONAL: Define Labels by Column Number ---
  # To use this, comment out the "ISSUE_LABEL_*" section below and uncomment this.
  # Note: Column numbers start at 1.
  # local label_column_numbers=(4 5 6 7 8) # Example: Use columns 4, 5, 6, 7, and 8 for labels

  # Stricter parsing loop to correctly identify columns
  IFS="$DELIMITER" read -r -a values <<< "$row_content"
  for i in "${!HEADERS[@]}"; do
    header=$(echo "${HEADERS[$i]}" | tr -d '\r')
    value=$(echo "${values[$i]}" | tr -d '\r')

    # --- Find values by header name (current method) ---
    if [[ "$header" == "LOCAL_ID" ]]; then
      local_id="$value"
      [ -n "$value" ] && issue_labels+=("ID:$value")
    elif [[ "$header" == "ISSUE_TITLE" ]]; then
      issue_title="$value"
    elif [[ "$header" == "ISSUE_BODY" ]]; then
      issue_body=$(echo "$value" | sed 's/;/\\n/g')
    elif [[ "$header" == ISSUE_LABEL_* ]]; then # This is the currently active method
      [ -n "$value" ] && issue_labels+=("$value")
    elif [[ "$header" == PROJECT_FIELD_* ]]; then
      [ -n "$value" ] && project_fields["${header#PROJECT_FIELD_}"]="$value"
    fi

    # --- Find values by column number (new, disabled method) ---
    # To use this, uncomment the next 3 lines and the 'label_column_numbers' array above.
    # for col_num in "${label_column_numbers[@]}"; do
    #   [ $((i + 1)) -eq "$col_num" ] && [ -n "$value" ] && issue_labels+=("$value")
    # done

  done

  if [ -z "$issue_title" ]; then
    echo "Skipping row with empty title."
    return
  fi

  # 1. Create all labels. `|| true` ignores errors if a label already exists.
  for label in "${issue_labels[@]}"; do
    random_color=$(openssl rand -hex 3)
    echo "ID:$local_id - Ensuring label exists: $label"
    gh label create "$label" --color "$random_color" --description "Auto-generated" || true
  done

  label_args=()
  for label in "${issue_labels[@]}"; do
    label_args+=("--label" "$label")
  done

  # 2. Check for and Create/Update Issue
  echo "ID:$local_id - Processing issue: '$issue_title'"
  existing_issue_url=$(gh issue list --search "in:title \"$issue_title\"" --state all --limit 1 --json url -q '.[0].url' || echo "")

  local issue_url=""
  if [ -n "$existing_issue_url" ]; then
    echo "ID:$local_id - Found existing issue. Updating: $existing_issue_url"
    issue_url=$existing_issue_url
    gh issue edit "$issue_url" --body "$issue_body"
    for label in "${issue_labels[@]}"; do
        gh issue edit "$issue_url" --add-label "$label" || true
    done
  else
    echo "ID:$local_id - No existing issue found. Creating new issue."
    issue_url=$(gh issue create --title "$issue_title" --body "$issue_body" "${label_args[@]}")
  fi

  if [ -z "$issue_url" ]; then
    echo "Failed to create or find issue."
    return 1
  fi

  # 3. Add to Project (DISABLED)
  # echo "ID:$local_id - Adding issue to project $PROJECT_NUMBER..."
  # item_id=$(gh project item-create "$PROJECT_NUMBER" --owner "@me" --issue "$issue_url" --format json | jq -r '.id')

  # if [ -z "$item_id" ]; then
  #   echo "Failed to add issue to project."
  #   return 1
  # fi

  # 4. Update Project Fields (DISABLED)
  # for field_name in "${!project_fields[@]}"; do
  #     field_value="${project_fields[$field_name]}"
  #     echo "ID:$local_id - Updating project field '$field_name' to '$field_value'"
  #     gh project item-edit --id "$item_id" --field-name "$field_name" --text "$field_value"
  # done
}

# --- Execution ---
# Use a while-read loop for safety and improved error logging
tail -n +2 "$DATA_FILE" | while IFS= read -r line; do
    error_output=$(process_row "$line" 2>&1) || {
        IFS= read -r local_id issue_title <<<$(echo "$line" | cut -f1,2)
        echo "---" >> "$ERROR_LOG_FILE"
        echo "Timestamp: $(date)" >> "$ERROR_LOG_FILE"
        echo "Failed to process row with LOCAL_ID: $local_id and Title: '$issue_title'" >> "$ERROR_LOG_FILE"
        echo "**Error Message:**" >> "$ERROR_LOG_FILE"
        echo "\`\`\`" >> "$ERROR_LOG_FILE"
        echo "$error_output" >> "$ERROR_LOG_FILE"
        echo "\`\`\`" >> "$ERROR_LOG_FILE"
    }
done

echo "Script finished."
if [ -f "$ERROR_LOG_FILE" ]; then
  echo "Some rows failed to process. Errors were logged to $ERROR_LOG_FILE"
fi
