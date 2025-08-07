# GitHub Automation Scripts

This project automates creating GitHub issues from a `.tsv` or `.csv` file.

---
## **How It Works**

1.  **Trigger**: The automation runs when you push changes to any file inside the `TSV_HERE/` directory.
2.  **Script Execution**: A GitHub Actions workflow finds and runs the `import_issues.sh` script.
3.  **Processing**: The script reads your data file and uses the GitHub CLI to create or update issues and labels.

The script is **idempotent**, meaning it updates existing issues instead of creating duplicates.

---
## **Files**

* **`/SCRIPTS/import_issues.sh`**: The main script that creates issues and labels.
* **`/SCRIPTS/purge_ALL.sh`**: A manual script to delete all issues and custom labels for a fresh start.
* **`/.github/workflows/project-importer.yml`**: The GitHub Actions workflow file that automates the process.
* **`/TSV_HERE/`**: The folder where you must place your data file (e.g., `PLANNERv8.tsv`).

---
## **Additional Workflows & Scripts**

This repository also contains additional, more specialized automation scripts.

* **Sub-issue Creation**
    * **Script**: `SCRIPTS/create_subissues.py`
    * **Workflow**: `.github/workflows/create_subissues.yml`
    * **Purpose**: Creates a checklist of sub-issues within a specified parent issue.

* **Project Management**
    * **Script**: `SCRIPTS/mass_project.py`
    * **Workflow**: `.github/workflows/mass_project.yml`
    * **Purpose**: Manages issues within a GitHub Project, including adding issues and updating custom fields.

* **Automated Purge**
    * **Workflow**: `.github/workflows/purge_ALL.yml`
    * **Purpose**: An automated, workflow-based alternative to the manual `purge_ALL.sh` script.

---
## **Setup**

### **1. Prepare Data File**

Place your `.tsv` or `.csv` file in the `TSV_HERE/` folder. The `import_issues.sh` script requires the following headers:
* `LOCAL_ID`
* `ISSUE_TITLE`
* `ISSUE_BODY`
* `ISSUE_LABEL_*` (e.g., `ISSUE_LABEL_1`, `ISSUE_LABEL_2`)

### **2. Run the Automation**

Commit and push your data file. The workflow will run automatically.

### **3. How to Purge (Manual)**

To delete all issues and labels, run this command from your local terminal:

```bash
bash SCRIPTS/purge_ALL.sh
```