# ////////////////////////////////////////////////////////////////////////////
#
# NAME: create_subissues.py
#
# AUTHOR: Your Name / Gemini
#
# VERSION: 1.0
#
# DATE: 2025-08-04
#
# PURPOSE: Reads a GitHub issue body, splits it by a semicolon delimiter, 
#          and creates a new sub-issue for each resulting string. It then
#          links the new sub-issues back to the parent issue via a
#          markdown task list.
#
# CHANGELOG:
#
#   1.0 - 2025-08-04: Initial release.
#       - Script created to parse a semicolon-delimited string.
#       - Creates sub-issues and links them to the parent.
#
# ////////////////////////////////////////////////////////////////////////////

import os
from github import Github, GithubException

def run_subissue_creation_from_delimiter():
    """
    Reads an issue body, splits it by a semicolon delimiter, and creates a sub-issue
    for each resulting string.
    """
    token = os.getenv("GITHUB_TOKEN")
    repo_name = os.getenv("REPO_NAME")
    issue_number_str = os.getenv("ISSUE_NUMBER")

    if not all([token, repo_name, issue_number_str]):
        print("Error: Missing one or more required environment variables (GITHUB_TOKEN, REPO_NAME, ISSUE_NUMBER).")
        exit(1)
        
    try:
        issue_number = int(issue_number_str)
    except ValueError:
        print(f"Error: Invalid issue number provided: '{issue_number_str}'. It must be an integer.")
        exit(1)

    try:
        g = Github(token)
        repo = g.get_repo(repo_name)
        parent_issue = repo.get_issue(number=issue_number)
        print(f"Successfully connected to repo '{repo_name}' and found parent issue #{issue_number}.")
    except GithubException as e:
        print(f"Error connecting to GitHub or finding the issue: {e}")
        exit(1)

    issue_body = parent_issue.body
    if not issue_body or not issue_body.strip():
        print("Issue body is empty. No sub-issues to create.")
        exit(0)

    sub_issue_titles = [part.strip() for part in issue_body.split(';') if part.strip()]

    if not sub_issue_titles:
        print("No non-empty parts found after splitting the issue body. Nothing to create.")
        exit(0)

    print(f"Found {len(sub_issue_titles)} sub-issues to create from the delimited string.")
    new_issue_numbers = []
    for title in sub_issue_titles:
        try:
            new_issue_body = f"This task was auto-generated from parent issue #{issue_number}."
            new_issue = repo.create_issue(title=title, body=new_issue_body)
            new_issue_numbers.append(new_issue.number)
            print(f"Created sub-issue: '{title}' -> Issue #{new_issue.number}")
        except GithubException as e:
            print(f"Failed to create issue for title '{title}': {e}")

    if not new_issue_numbers:
        print("Warning: No sub-issues were successfully created.")
        exit(0)
        
    print(f"\nLinking {len(new_issue_numbers)} sub-issues to parent issue #{issue_number}...")
    task_list_markdown = "\n\n### Auto-Generated Sub-issues\n"
    for num in new_issue_numbers:
        task_list_markdown += f"- [ ] #{num}\n"
    
    try:
        updated_body = f"{issue_body}{task_list_markdown}"
        parent_issue.edit(body=updated_body)
        print("Parent issue updated successfully with sub-issue list!")
    except GithubException as e:
        print(f"Failed to update parent issue #{issue_number}: {e}")

if __name__ == "__main__":
    run_subissue_creation_from_delimiter()