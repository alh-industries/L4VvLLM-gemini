# ////////////////////////////////////////////////////////////////////////////
#
# NAME: project_issues.py
#
# AUTHOR: Your Name / Gemini
#
# VERSION: 2.1
#
# DATE: 2025-08-04
#
# PURPOSE: Updates GitHub Project items based on data from a TSV file.
#          It maps TSV column headers like 'PROJECT_FIELD_Status' to project
#          fields and sets the corresponding values for each issue.
#          It can now create new single-select options on the fly.
#
# PREREQUISITES:
#   - GitHub CLI ('gh') must be installed and authenticated.
#   - The project and its custom fields must already exist.
#
# CHANGELOG:
#
#   2.1 - 2025-08-04: Refactored script name to project_issues.py.
#
#   2.0 - 2025-08-04: Added dynamic creation of single-select options.
#
#   1.0 - 2025-08-04: Initial release.
#
# ////////////////////////////////////////////////////////////////////////////

import csv
import json
import os
import subprocess
import time

# --- CONFIGURATION ---
PROJECT_ID = os.getenv("PROJECT_ID")
TSV_FILE_PATH = os.getenv("TSV_FILE_PATH")
ISSUE_NUMBER_COLUMN = os.getenv("ISSUE_NUMBER_COLUMN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN") # Needed for GraphQL requests

def run_gh_command(command):
    """Executes a shell command and returns its JSON output."""
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True, shell=True)
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {command}\n{e.stderr}")
        return None
    except json.JSONDecodeError:
        return None

def run_graphql_query(query):
    """Helper to run a raw GraphQL query using gh api."""
    # Using gh api graphql is easier than 'requests' as it handles auth
    command = f"gh api graphql -f query='{query}'"
    return run_gh_command(command)

def get_project_data(project_id):
    """Fetches all field and item data for a project and creates lookup maps."""
    print("Fetching project data...")
    field_list_command = f"gh project field-list {project_id} --format json"
    fields_data = run_gh_command(field_list_command)
    if not fields_data: raise Exception("Could not fetch project fields.")

    field_map, option_map = {}, {}
    for field in fields_data.get('fields', []):
        field_map[field['name']] = field
        if 'options' in field:
            option_map[field['id']] = {opt['name']: opt['id'] for opt in field['options']}
    
    item_list_command = f"gh project item-list {project_id} --limit 500 --format json"
    items_data = run_gh_command(item_list_command)
    if not items_data: raise Exception("Could not fetch project items.")
    
    item_map = {item['content']['number']: item['id'] for item in items_data.get('items', []) if 'content' in item and 'number' in item['content']}
            
    print("Successfully built project data maps.")
    return field_map, option_map, item_map

def ensure_select_option_exists(project_node_id, field_data, new_option_name):
    """
    Ensures a single-select option exists, creating it via GraphQL if it doesn't.
    Returns the ID of the option.
    """
    field_id = field_data['id']
    existing_options = field_data.get('options', [])
    
    for option in existing_options:
        if option['name'] == new_option_name:
            return option['id']

    print(f"  - Option '{new_option_name}' not found for field '{field_data['name']}'. Creating it...")
    
    new_options_payload = [f"{{ name: \\\"{opt['name']}\\\" }}" for opt in existing_options]
    new_options_payload.append(f"{{ name: \\\"{new_option_name}\\\" }}")
    options_string = ', '.join(new_options_payload)

    mutation = f'''
    mutation {{
      updateProjectV2Field(
        input: {{
          projectId: "{project_node_id}",
          fieldId: "{field_id}",
          singleSelect: {{ options: [{options_string}] }}
        }}
      ) {{
        field {{
          ... on ProjectV2SingleSelectField {{
            id
            options {{ id name }}
          }}
        }}
      }}
    }}
    '''
    
    response = run_graphql_query(mutation.replace('\n', ' '))
    if response:
        updated_options = response['data']['updateProjectV2Field']['field']['options']
        for opt in updated_options:
            if opt['name'] == new_option_name:
                print(f"  - Successfully created option '{new_option_name}'.")
                field_data['options'].append(opt)
                return opt['id']
    
    print(f"  - Error: Failed to create or find new option '{new_option_name}'.")
    return None

def main():
    """Main execution function."""
    if not all([PROJECT_ID, TSV_FILE_PATH, ISSUE_NUMBER_COLUMN, GITHUB_TOKEN]):
        print("Error: One or more environment variables are not set.")
        exit(1)

    try:
        project_view_data = run_gh_command(f"gh project view {PROJECT_ID} --format json")
        if not project_view_data: raise Exception("Could not get project view data.")
        project_node_id = project_view_data['id']

        field_name_to_data, _, issue_no_to_item_id = get_project_data(PROJECT_ID)
    except Exception as e:
        print(f"Fatal error during setup: {e}")
        return

    with open(TSV_FILE_PATH, mode='r', encoding='utf-8') as tsvfile:
        reader = csv.DictReader(tsvfile, delimiter='\t')
        
        for i, row in enumerate(reader):
            issue_number = int(row.get(ISSUE_NUMBER_COLUMN, 0))
            item_id = issue_no_to_item_id.get(issue_number)

            if not item_id: continue

            print(f"\nProcessing Issue #{issue_number}...")

            for header, value in row.items():
                if not header.startswith("PROJECT_FIELD_") or not value: continue

                field_name = header.replace("PROJECT_FIELD_", "")
                field_data = field_name_to_data.get(field_name)

                if not field_data:
                    print(f"  - Warning: Field '{field_name}' not found. Skipping.")
                    continue

                field_id = field_data['id']
                command = None

                if field_data['dataType'] == 'SINGLE_SELECT':
                    option_id = ensure_select_option_exists(project_node_id, field_data, value)
                    if option_id:
                        command = f"gh project item-edit --id {item_id} --field-id {field_id} --single-select-option-id {option_id}"
                elif field_data['dataType'] == 'DATE': 
                    command = f"gh project item-edit --id {item_id} --field-id {field_id} --date '{value}'"
                else: # Assumes TEXT or NUMBER
                    command = f"gh project item-edit --id {item_id} --field-id {field_id} --text '{value}'"
                
                if command:
                    print(f"  - Setting '{field_name}' to '{value}'...")
                    subprocess.run(command, shell=True, capture_output=True)

            time.sleep(1) 

    print("\nProcessing complete.")

# (Commented out examples remain for reference)

if __name__ == "__main__":
    main()