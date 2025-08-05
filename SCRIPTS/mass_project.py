# ////////////////////////////////////////////////////////////////////////////
#
# NAME: mass_project.py
#
# AUTHOR: Your Name / Gemini
#
# VERSION: 2.0
#
# DATE: 2025-08-04
#
# PURPOSE: Creates one or more new GitHub Projects from scratch based on
#          all .tsv files found in the /TSV_HERE/ directory. For each TSV,
#          it creates a project, populates it with all repo issues, and
#          configures fields and values.
#
# PREREQUISITES:
#   - GitHub CLI ('gh') must be installed and authenticated with 'project' scope.
#
# CHANGELOG:
#
#   2.0 - 2025-08-04:
#       - Renamed to mass_project.py.
#       - Refactored to read all .tsv files from the /TSV_HERE/ directory.
#
#   1.0 - 2025-08-04: Initial release as create_and_populate_project.py.
#
# ////////////////////////////////////////////////////////////////////////////

import csv
import json
import os
import random
import subprocess
import time
from datetime import datetime

# --- CONFIGURATION ---
OWNER = os.getenv("GITHUB_OWNER")
REPO_NAME = os.getenv("GITHUB_REPO")
# The directory where the script will look for .tsv files.
TSV_DIRECTORY = os.getenv("TSV_DIRECTORY", "TSV_HERE")

def run_command(command, check=True):
    """Executes a shell command and optionally returns its JSON output."""
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=check, shell=True)
        if result.stdout:
            return json.loads(result.stdout)
        return None
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {command}\n{e.stderr}")
        return None
    except json.JSONDecodeError:
        return None

def get_random_color():
    """Returns a random color for a single-select option."""
    colors = ["GRAY", "BLUE", "GREEN", "ORANGE", "RED", "PINK", "PURPLE", "YELLOW"]
    return random.choice(colors)

def analyze_tsv_for_fields(tsv_path):
    """Reads a TSV to determine project title, field definitions, and data."""
    print(f"Analyzing TSV file: {tsv_path}")
    with open(tsv_path, mode='r', encoding='utf-8') as file:
        reader = csv.DictReader(file, delimiter='\t')
        data = list(reader)
        headers = reader.fieldnames

    project_title = data[0].get("PROJECT_TITLE", f"Project from {os.path.basename(tsv_path)}")
    field_definitions = {}
    project_field_headers = [h for h in headers if h.startswith("PROJECT_FIELD_")]

    for header in project_field_headers:
        field_name = header.replace("PROJECT_FIELD_", "")
        values = [row[header] for row in data if row.get(header)]
        if not values: continue

        field_type = "TEXT"
        unique_values = sorted(list(set(values)))
        try:
            datetime.strptime(values[0], '%Y-%m-%d')
            field_type = "DATE"
        except (ValueError, IndexError):
            if 1 < len(unique_values) <= 15:
                 field_type = "SINGLE_SELECT"

        field_definitions[field_name] = { "type": field_type, "options": unique_values if field_type == "SINGLE_SELECT" else [] }
    
    return project_title, field_definitions, data

def process_tsv_file(tsv_path):
    """Runs the entire creation and population process for a single TSV file."""
    project_title, field_definitions, tsv_data = analyze_tsv_for_fields(tsv_path)

    print(f"\nCreating project '{project_title}'...")
    create_project_cmd = f"gh project create --owner {OWNER} --title '{project_title}' --format json"
    project_data = run_command(create_project_cmd)
    if not project_data: return
    project_number = project_data['number']
    print(f"Successfully created project #{project_number}")
    time.sleep(1)

    print("\nCreating project fields...")
    for name, definition in field_definitions.items():
        field_type = definition['type']
        print(f"  - Creating field '{name}' of type '{field_type}'...")
        command = f"gh project field-create {project_number} --owner {OWNER} --name '{name}' --data-type {field_type}"
        if field_type == "SINGLE_SELECT":
            options_str = ",".join([f'"{opt}"' for opt in definition['options']])
            command += f" --single-select-options {options_str}"
        run_command(command)
        # This sleep is sufficient to prevent primary rate limit issues.
        time.sleep(1)

    print(f"\nImporting all open issues from '{OWNER}/{REPO_NAME}'...")
    issues_list_cmd = f"gh issue list -R {OWNER}/{REPO_NAME} --json number --limit 500"
    issues = run_command(issues_list_cmd)
    
    issue_no_to_item_id = {}
    if issues:
        for issue in issues:
            issue_url = f"https://github.com/{OWNER}/{REPO_NAME}/issues/{issue['number']}"
            print(f"  - Adding issue #{issue['number']}...")
            add_item_cmd = f"gh project item-add {project_number} --owner {OWNER} --url {issue_url} --format json"
            item_data = run_command(add_item_cmd)
            if item_data:
                issue_no_to_item_id[issue['number']] = item_data['id']
            time.sleep(1)

    print("\nPopulating project fields for each issue...")
    field_list_data = run_command(f"gh project field-list {project_number} --owner {OWNER} --format json")
    field_details = {f['name']: f for f in field_list_data.get('fields', [])}
    option_details = { f['id']: {opt['name']: opt['id'] for opt in f.get('options', [])} for f in field_list_data.get('fields', []) }

    for row in tsv_data:
        issue_number_str = row.get("issue_number")
        if not issue_number_str: continue
        
        item_id = issue_no_to_item_id.get(int(issue_number_str))
        if not item_id: continue

        print(f"\nUpdating fields for Issue #{issue_number_str}...")
        for header, value in row.items():
            if not header.startswith("PROJECT_FIELD_") or not value: continue
            
            field_name = header.replace("PROJECT_FIELD_", "")
            field = field_details.get(field_name)
            if not field: continue
            field_id = field['id']
            command = None
            
            if field['dataType'] == 'SINGLE_SELECT':
                option_id = option_details.get(field_id, {}).get(value)
                if not option_id: continue
                command = f"gh project item-edit --id {item_id} --field-id {field_id} --single-select-option-id {option_id}"
            elif field['dataType'] == 'DATE':
                command = f"gh project item-edit --id {item_id} --field-id {field_id} --date '{value}'"
            else:
                command = f"gh project item-edit --id {item_id} --field-id {field_id} --text '{value}'"
            
            if command:
                print(f"  - Setting '{field_name}' to '{value}'...")
                run_command(command, check=False)
        time.sleep(1)

def main():
    """Main execution function to find and process all TSV files."""
    if not all([OWNER, REPO_NAME]):
        print("Error: GITHUB_OWNER or GITHUB_REPO env vars not set.")
        exit(1)

    if not os.path.isdir(TSV_DIRECTORY):
        print(f"Error: Directory '{TSV_DIRECTORY}' not found.")
        exit(1)

    tsv_files = [f for f in os.listdir(TSV_DIRECTORY) if f.endswith('.tsv')]

    if not tsv_files:
        print(f"No .tsv files found in '{TSV_DIRECTORY}'. Nothing to do.")
        return

    print(f"Found {len(tsv_files)} TSV files to process: {tsv_files}")
    for tsv_file in tsv_files:
        full_path = os.path.join(TSV_DIRECTORY, tsv_file)
        process_tsv_file(full_path)
        print("-" * 50)

    print("\n\nAll processing complete!")

if __name__ == "__main__":
    main()