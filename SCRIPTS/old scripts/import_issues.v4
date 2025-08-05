#!/bin/bash
# ===================================================================================
#
# GITHUB PROJECT AUTOMATION SCRIPT (v4.0 - Projects Enabled)
#
# This script reads a TSV/CSV file to create and update GitHub issues, labels,
# and project items, including custom fields.
#
# --- CHANGELOG ---
# v3.1: Projects functionality disabled.
# v4.0: Re-enabled and finalized project integration. Uses modern `item-edit`
#       syntax to set custom fields by name.
#
# ===================================================================================

# Stop script on any error
set -e

# ===========================================
# PLEASE EDIT THESE VARIABLES
# ===========================================
PROJECT_NUMBER="8"
DATA_FILE_PATH="TSV_HERE/"
# ===========================================


# --- Script setup and initialization ---
DATA_FILE=$(find "$DATA_FILE_PATH" -maxdepth 1 \( -name "*.tsv" -o -name "*.csv" \) -print -quit)
ERROR_LOG_FILE="${DATA_FILE_PATH}errors.md"

if [ -z "$DATA_FILE" ]; then
  echo "Error: No .tsv or .csv file found in '$DATA_FILE_PATH'. Exiting."
  exit 1
fi

echo "Processing file: $DATA_FILE"
# Determine delimiter by file extension
DELIMITER=$'\t'
if [[ "$DATA_FILE" == *.csv ]]; then
  DELIMITER=','
fi

# Clean up previous error log
rm -f "$ERROR_LOG_FILE"

# Read the header row to map column names to indices
IFS="$DELIMITER" read -r -a HEADERS < <(head -n 1 "$DATA_FILE")

# --- Main Processing Function ---
# This function processes a single row from the data file.
process_row() {
  local row_content="$1"
  local local_id=""
  local issue_title=""
  local issue_body=""
  local issue_labels=()
  declare -A project_fields

  # === PARSE THE ROW ===
  # Read the provided row and assign values to variables based on the header.
  IFS="$DELIMITER" read -r -a values <<< "$row_content"
  for i in "${!HEADERS[@]}"; do
    header=$(echo "${HEADERS[$i]}" | tr -d '\r')
    value=$(echo "${values[$i]}" | tr -d '\r')

    if [[ "$header" == "LOCAL_ID" ]]; then
      local_id="$value"
      # Automatically add the Local ID as a label for easy tracking
      [ -n "$value" ] && issue_labels+=("ID:$value")

    elif [[ "$header" == "ISSUE_TITLE" ]]; then
      issue_title="$value"

    elif [[ "$header" == "ISSUE_BODY" ]]; then
      # Replace semicolons with newlines to format the issue body
      issue_body=$(echo "$value" | sed 's/;/\\n/g')

    elif [[ "$header" == ISSUE_LABEL_* ]]; then
      # This is ISSUE specific logic
      [ -n "$value" ] && issue_labels+=("$value")

    elif [[ "$header" == PROJECT_FIELD_* ]]; then
      # This is PROJECT specific logic
      # The field name is the header minus "PROJECT_FIELD_"
      [ -n "$value" ] && project_fields["${header#PROJECT_FIELD_}"]="$value"
    fi
  done

  # Skip row if it doesn't have a title
  if [ -z "$issue_title" ]; then
    echo "Skipping row with empty title."
    return
  fi

  # === PROCESS ISSUE AND LABELS ===
  echo "ID:$local_id - Processing issue: '$issue_title'"

  # 1. Create all labels first. `|| true` ignores errors if a label already exists.
  for label in "${issue_labels[@]}"; do
    random_color=$(openssl rand -hex 3)
    gh label create "$label" --color "$random_color" --description "Auto-generated from script" || true
  done

  # Prepare label arguments for the create command
  label_args=()
  for label in "${issue_labels[@]}"; do
    label_args+=("--label" "$label")
  done

  # 2. Check if issue exists (Idempotency).
  existing_issue_url=$(gh issue list --search "in:title \"$issue_title\"" --state all --limit 1 --json url -q '.[0].url' || echo "")

  local issue_url=""
  if [ -n "$existing_issue_url" ]; then
    echo "ID:$local_id - Found existing issue. Updating: $existing_issue_url"
    issue_url=$existing_issue_url
    # Update the body and labels of the existing issue
    gh issue edit "$issue_url" --body "$issue_body"
    gh issue edit "$issue_url" --add-label "$(IFS=,; echo "${issue_labels[*]}")" || true
  else
    echo "ID:$local_id - No existing issue found. Creating new issue."
    issue_url=$(gh issue create --title "$issue_title" --body "$issue_body" "${label_args[@]}")
  fi

  if [ -z "$issue_url" ]; then
    echo "Failed to create or find issue."
    return 1 # Triggers error logging
  fi

  # === PROCESS PROJECT INTEGRATION ===

  # 3. Add issue to the project and get the project item ID.
  echo "ID:$local_id - Adding issue to project $PROJECT_NUMBER..."
  # The project number is a positional argument, it comes before the flags.
  item_id=$(gh project item-add "$issue_url" --owner "@me" --project-id "$PROJECT_NUMBER" --format json | jq -r '.id' || echo "")
  
  if [ -z "$item_id" ]; then
      echo "Warning: Could not add issue #$issue_number to project. It might already be there. Trying to find it..."
      # If adding fails, it might already be in the project. We need to find its ID.
      item_id=$(gh project item-list "$PROJECT_NUMBER" --owner "@me" --format json | jq --argjson issueNumber "$(echo "$issue_url" | rev | cut -d'/' -f1 | rev)" -r '.items[] | select(.content.number == $issueNumber) | .id')
  fi

  if [ -z "$item_id" ]; then
      echo "Failed to find or add issue '$issue_title' to project $PROJECT_NUMBER."
      return 1 # Triggers error logging
  fi
  
  # 4. Loop through and update all custom project fields for the item.
  for field_name in "${!project_fields[@]}"; do
      field_value="${project_fields[$field_name]}"
      echo "ID:$local_id - Updating project field '$field_name' to '$field_value'"
      
      # This powerful `item-edit` command sets fields by name.
      # It requires a modern version of the gh CLI.
      gh project item-edit --id "$item_id" --field-name "$field_name" --text "$field_value"
  done
}

# --- SCRIPT EXECUTION ---
# Use a while-read loop for safety and improved error logging.
# It processes the file line-by-line, starting after the header.
tail -n +2 "$DATA_FILE" | while IFS= read -r line; do
    # For each line, attempt to run process_row. Capture STDERR to a variable on failure.
    error_output=$(process_row "$line" 2>&1) || {
        # This block runs if process_row fails (returns non-zero).
        local_id=$(echo "$line" | cut -f1) # Get Local ID for logging
        title=$(echo "$line" | cut -f2) # Get Title for logging
        echo "---" >> "$ERROR_LOG_FILE"
        echo "Timestamp: $(date)" >> "$ERROR_LOG_FILE"
        echo "Failed to process row with LOCAL_ID: $local_id and Title: '$title'" >> "$ERROR_LOG_FILE"
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