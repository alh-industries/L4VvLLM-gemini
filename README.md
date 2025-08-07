# GitHub Automation Suite

**Objective**: Automate GitHub issue, label, and project management via a `.tsv` file as the single source of truth.

---
## **Architecture**

* **Primary Trigger**: The automation runs when you push changes to any file inside the `/TSV_HERE/` directory.
* **Core Logic**: The system is composed of discrete Bash and Python scripts located in the `/SCRIPTS/` directory. These are executed by corresponding `.yml` workflows.
* **Data-Driven**: Scripts are not hardcoded. They dynamically build and execute `gh` commands by parsing the headers of the `.tsv` data file.
* **Idempotency**: Scripts update existing issues/labels rather than creating duplicates.
* **Rate-Limit Safe**: A `sleep 1` command is used in loops that make multiple API calls to prevent rate-limiting.

---
## **Component Manifest**

### **Workflows (`/.github/workflows/`)**

* **`project-importer.yml`**: Main workflow. Triggers `import_issues.sh` on data file changes.
* **`create_subissues.yml`**: Triggers `create_subissues.sh` to add task checklists to existing issues.
* **`mass_project.yml`**: Triggers `mass_project.sh` to add issues to projects and update their custom fields.
* **`purge_ALL.yml`**: A manually triggered workflow to delete all issues and custom labels.

### **Scripts (`/SCRIPTS/`)**

* **`import_issues.sh`**: Creates/updates GitHub issues and labels from the data file.
* **`create_subissues.sh`**: Parses an issue's body, splits it by semicolons, and adds the content as a sub-task checklist.
* **`mass_project.sh`**: Manages adding issues to a GitHub Project and updating their custom fields.
* **`purge_ALL.sh`**: A manual utility script for local use to delete all issues and custom labels.

### **Data (`/TSV_HERE/`)**

* This directory contains the `.tsv` data file that drives the automation. Required headers for the `import_issues.sh` script include `LOCAL_ID`, `ISSUE_TITLE`, `ISSUE_BODY`, and `ISSUE_LABEL_*`.

---
## **To-Do**

* **Create Master Script**: Develop a single script to execute all other scripts in the correct order.
* **Centralize Configuration**: Move all configurable variables (e.g., `PROJECT_NUMBER`, `DATA_FILE_PATH`) into a single `config.env` file to be sourced by all scripts.
* **Standardize Language**: Refactor Bash scripts into Python for consistency and to leverage libraries like `pandas` for all data manipulation.
* **Unify Error Logging**: Update Python scripts to log errors to the `TSV_HERE/errors.md` file, creating a single error log for the entire project.