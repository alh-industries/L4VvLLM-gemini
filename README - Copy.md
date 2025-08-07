# GitHub Project Automation from TSV/CSV

This repository contains a GitHub Actions workflow designed to automate the creation and management of GitHub Issues by reading data from a `.tsv` or `.csv` file.

## How It Works

The workflow is triggered when changes are pushed to the data file (e.g., `PLANNERv6.tsv`) located in the `TSV_HERE/` directory. A Bash script then reads the file row by row, parsing the columns to create or update issues, add labels, and, optionally, manage GitHub Project items.

The script is designed to be **idempotent**, meaning if an issue with the same title already exists, the script will update its body and labels instead of creating a duplicate.

## Key Files

  * **`.github/workflows/project-importer.yml`**: This is the main GitHub Actions workflow file. It defines the trigger (a push to files inside `TSV_HERE/`) and runs the import script.
  * **`import_issues.sh`**: This is the core script that performs all the logic. It reads the data file, communicates with the GitHub API (via the `gh` CLI), and handles issue/label creation and updates.
  * **`purge_issues.sh`**: A **manual** utility script for completely purging all issues from the repository. This is useful for performing a clean, fresh import.
  * **`TSV_HERE/`**: This directory is the designated location for your data file (e.g., `PLANNERv6.tsv`). The workflow is configured to watch this specific folder for changes.

## Setup and Usage

### 1\. Configure the Import Script

Before running, you must edit the user variables at the top of the `import_issues.sh` script:

```bash
# ============================================
# PLEASE EDIT THESE VARIABLES
# ============================================
PROJECT_NUMBER="8"
DATA_FILE_PATH="TSV_HERE/"
# ============================================
```

### 2\. Prepare Your Data File

  * Place your `.tsv` or `.csv` file inside the `TSV_HERE/` directory.
  * The script expects specific headers to function correctly:
      * `LOCAL_ID`: Used for logging and is automatically added as a label (e.g., `ID:1`).
      * `ISSUE_TITLE`: The title of the GitHub Issue.
      * `ISSUE_BODY`: The body content of the issue. The script will automatically convert semicolons (`;`) into newlines.
      * `ISSUE_LABEL_*`: Any column starting with this prefix will be used to create a label.
      * `PROJECT_FIELD_*`: (Currently Disabled) Any column starting with this prefix will be used to update a field in your GitHub Project.

### 3\. Running the Workflow

The workflow runs automatically. Simply edit your `.tsv` file, commit the changes, and push them to the `main` branch. The "Actions" tab in your repository will show the workflow progress.

### 4\. How to Purge Issues (Manual Step)

If you need to start fresh, you can run the purge script from your local machine.

```bash
# Make sure you have the GitHub CLI installed and are logged in.
# From your repository's root directory, run:
bash purge_issues.sh
```

## Current Status & Features

  * ✅ **Issue Creation & Updates:** The script successfully creates new issues and updates existing ones based on the `ISSUE_TITLE`.
  * ✅ **Label Management:**
      * Labels are automatically created from any `ISSUE_LABEL_*` column.
      * The `LOCAL_ID` value is also added as a prefixed label (e.g., `ID:123`).
      * Labels are assigned a random color upon creation.
      * The script will not fail if a label already exists.
  * ✅ **Error Logging:** If any row fails to process, detailed information is logged to `TSV_HERE/errors.md`.
  * ⚠️ **Project Integration (Currently Disabled):** All commands related to adding issues to GitHub Projects and updating their fields are **commented out** in the `import_issues.sh` script.

### To Enable Project Integration:

1.  Follow the instructions to [create a Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) with `repo` and `project` scopes.
2.  Add this token as a **Repository Secret** named `GH_PAT`.
3.  Uncomment the project-related command blocks at the bottom of the `process_row` function in `import_issues.sh`.
4.  Ensure your `project-importer.yml` file is configured to use the `GH_PAT` secret.
