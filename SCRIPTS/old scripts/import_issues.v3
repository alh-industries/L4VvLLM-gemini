#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# ===================================================================================
#
# GITHUB PROJECT AUTOMATION SCRIPT
#
# This script reads a TSV/CSV file to create and update GitHub issues, labels,
# and project items.
#
# ===================================================================================


# ============================================
# PLEASE EDIT THESE VARIABLES
# ============================================
# The number of your GitHub Project (e.g., the '123' in 'https://github.com/users/your-user/projects/123')
PROJECT_NUMBER="6"

# The folder path where your .tsv or .csv data file is located. Must end with a slash.
DATA_FILE_PATH="TSV_HERE/"

# The maximum number of parallel jobs to run.
# A lower number is safer to avoid GitHub API rate limits. Recommended: 2-4.
MAX_PARALLEL_JOBS=4
# ============================================


# --- Script setup and initialization ---
# Find the first .tsv or .csv file in the data folder
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

# Clean up previous error log if it exists
rm -f "$ERROR_LOG_FILE"

# --- Main Processing Logic ---
# Read the header row to map column names to indices
IFS="$DELIMITER" read -r -a HEADERS < <(head -n 1 "$DATA_FILE")

# Function to process a single row from the data file
# This function will be exported to be used by xargs for parallel processing.
process_row() {
  local row_content="$1"
  local issue_title=""
  local issue_body=""
  local issue_labels=()
  declare -A project_fields

  # Parse the row based on the header map
  IFS="$DELIMITER" read -r -a values <<< "$row_content"
  for i in "${!HEADERS[@]}"; do
    header=$(echo "${HEADERS[$i]}" | tr -d '\r') # Clean header
    value=$(echo "${values[$i]}" | tr -d '\r')  # Clean value

    if [[ "$header" == "ISSUE_TITLE" ]]; then
      issue_title="$value"
    elif [[ "$header" == "ISSUE_BODY" ]]; then
      # Replace semicolons with newlines for the issue body
      issue_body=$(echo "$value" | sed 's/;/\\n/g')
    elif [[ "$header" == ISSUE_LABEL_* ]]; then
      [ -n "$value" ] && issue_labels+=("$value")
    elif [[ "$header" == PROJECT_FIELD_* ]]; then
      [ -n "$value" ] && project_fields["${header#PROJECT_FIELD_}"]="$value"
    fi
  done

  # Skip if title is empty
  if [ -z "$issue_title" ]; then
    echo "Skipping row with empty title."
    return
  fi

  # 1. Create all labels with a random color.
  for label in "${issue_labels[@]}"; do
    random_color=$(openssl rand -hex 3)
    echo "Ensuring label exists: $label with random color #$random_color"
    gh label create "$label" --color "$random_color" --description "Auto-generated from user spreadsheet" || true
  done

  # Prepare label arguments for the 'gh issue create' command
  label_args=()
  for label in "${issue_labels[@]}"; do
    label_args+=("--label" "$label")
  done

  # 2. Check for an existing issue by title (Idempotency)
  echo "Checking for existing issue titled: '$issue_title'"
  existing_issue_url=$(gh issue list --search "in:title \"$issue_title\"" --state all --limit 1 --json url -q '.[0].url' || echo "")

  local issue_url=""
  if [ -n "$existing_issue_url" ]; then
    echo "Found existing issue. Updating: $existing_issue_url"
    issue_url=$existing_issue_url
    # Edit existing issue's body
    gh issue edit "$issue_url" --body "$issue_body"
    # Edit existing issue's labels one by one
    for label in "${issue_labels[@]}"; do
        gh issue edit "$issue_url" --add-label "$label" || true
    done
  else
    echo "No existing issue found. Creating new issue."
    # Create new issue with all arguments prepared
    issue_url=$(gh issue create --title "$issue_title" --body "$issue_body" "${label_args[@]}" --json url -q '.url')
  fi

  if [ -z "$issue_url" ]; then
    echo "Failed to create or find issue: '$issue_title'"
    return 1 # Fails the command for error logging
  fi

  echo "Issue URL: $issue_url"

  # 3. Add issue to the project and get the project item ID
  echo "Adding issue to project $PROJECT_NUMBER..."
  item_id=$(gh project item-create --owner "@me" --project "$PROJECT_NUMBER" --issue "$issue_url" --format json | jq -r '.id')

  if [ -z "$item_id" ]; then
    echo "Failed to add issue '$issue_title' to project."
    return 1
  fi

  # 4. Update all custom project fields for the item
  for field_name in "${!project_fields[@]}"; do
      field_value="${project_fields[$field_name]}"
      echo "Updating project field '$field_name' with value '$field_value' for item $item_id"
      gh project item-edit --id "$item_id" --field-name "$field_name" --text "$field_value"
  done
}

# Export the function and variables so xargs can use them
export -f process_row
export DELIMITER
export HEADERS
export PROJECT_NUMBER

# Log errors function
log_error() {
  local row_data="$1"
  echo "---" >> "$ERROR_LOG_FILE"
  echo "Timestamp: $(date)" >> "$ERROR_LOG_FILE"
  echo "Failed to process row:" >> "$ERROR_LOG_FILE"
  echo "\`\`\`" >> "$ERROR_LOG_FILE"
  echo "$row_data" >> "$ERROR_LOG_FILE"
  echo "\`\`\`" >> "$ERROR_LOG_FILE"
}
export -f log_error

# --- Execution ---
# Skip header row, then pipe rows into xargs for parallel processing.
tail -n +2 "$DATA_FILE" | xargs -d '\n' -P "$MAX_PARALLEL_JOBS" -I {} bash -c 'process_row "{}" || log_error "{}"'

echo "Script finished."
if [ -f "$ERROR_LOG_FILE" ]; then
  echo "Errors were logged to $ERROR_LOG_FILE"
  exit 1
else
  echo "All rows processed successfully."
fi
