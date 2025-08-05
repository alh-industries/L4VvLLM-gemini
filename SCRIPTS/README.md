# GitHub Automation Suite

This repository contains a suite of automation tools designed to manage GitHub issues and projects programmatically.

| Automation Name | Workflow File (`.github/workflows/`) | Script File (`SCRIPTS/`) | Purpose & Triggers |
| :--- | :--- | :--- | :--- |
| **Bulk Issue Importer** | `project-importer.yml` | `import_issues.py` | Imports new, top-level issues into the repository from a static `issues.tsv` file at the project root. <br> **Triggers:** On a schedule or manually. |
| **Sub-issue Creator** | `create_subissues.yml` | `create_subissues.py` | Creates multiple sub-issues from a single issue's body, using a semicolon (`;`) as a delimiter. <br> **Triggers:** When a new issue is opened or manually. |
| **Mass Project Creator** | `mass_project.yml` | `mass_project.py` | For each `.tsv` file found in the `/TSV_HERE/` directory, it builds a complete GitHub Project from scratch, imports all repo issues, and populates their fields. <br> **Triggers:** Manually only. |
| **Project Issue Sync** | `project_issues.yml` | `project_issues.py` | Updates the fields of issues already within a specific project, syncing their values from a TSV file. It can create new single-select options on the fly. <br> **Triggers:** On a schedule or manually. |


==============================================================================================================================================================
                                                      GitHub Automation Suite
==============================================================================================================================================================
This repository contains a suite of automation tools designed to manage GitHub issues and projects programmatically.


| Automation Name         | Workflow File (.github/workflows/) | Script File (SCRIPTS/) | Purpose & Triggers                                                                                                                         |
|-------------------------|------------------------------------|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| Bulk Issue Importer     | project-importer.yml               | import_issues.py       | Imports new, top-level issues into the repository from a static `issues.tsv` file at the project root. Triggers: On a schedule or manually.  |
| Sub-issue Creator       | create_subissues.yml               | create_subissues.py    | Creates multiple sub-issues from a single issue's body, using a semicolon (;) as a delimiter. Triggers: When a new issue is opened or manually. |
| Mass Project Creator    | mass_project.yml                   | mass_project.py        | For each .tsv file found in the /TSV_HERE/ directory, it builds a complete GitHub Project from scratch, imports all repo issues, and populates their fields. Triggers: Manually only. |
| Project Issue Sync      | project_issues.yml                 | project_issues.py      | Updates the fields of issues already within a specific project, syncing their values from a TSV file. It can create new single-select options on the fly. Triggers: On a schedule or manually. |




**GitHub Automation Suite**

A collection of tools to programmatically manage GitHub issues and projects.

**1. Bulk Issue Importer**
    * **Workflow File**: `.github/workflows/project-importer.yml`
    * **Script File**: `SCRIPTS/import_issues.py`
    * **Purpose**: Imports new, top-level issues into the repository from a static `issues.tsv` file at the project root.
    * **Triggers**:
        * On a schedule
        * Manually

**2. Sub-issue Creator**
    * **Workflow File**: `.github/workflows/create_subissues.yml`
    * **Script File**: `SCRIPTS/create_subissues.py`
    * **Purpose**: Creates multiple sub-issues from a single issue's body, using a semicolon (`;`) as a delimiter.
    * **Triggers**:
        * When a new issue is opened
        * Manually

**3. Mass Project Creator**
    * **Workflow File**: `.github/workflows/mass_project.yml`
    * **Script File**: `SCRIPTS/mass_project.py`
    * **Purpose**: For each `.tsv` file found in the `/TSV_HERE/` directory, it builds a complete GitHub Project from scratch, imports all repository issues, and populates their fields.
    * **Triggers**:
        * Manually only

**4. Project Issue Sync**
    * **Workflow File**: `.github/workflows/project_issues.yml`
    * **Script File**: `SCRIPTS/project_issues.py`
    * **Purpose**: Updates the fields of issues already within a specific project by syncing their values from a TSV file. It can create new single-select options on the fly.
    * **Triggers**:
        * On a schedule
        * Manually



