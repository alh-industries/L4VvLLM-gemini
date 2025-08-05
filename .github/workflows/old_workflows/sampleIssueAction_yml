# instructions: https://docs.github.com/en/actions/how-tos/use-cases-and-examples/project-management/adding-labels-to-issues
# Change the value for LABELS to the list of labels that you want to add to the issue. The label(s) must exist for your repository. 
# Separate multiple labels with commas. For example: help wanted,good first issue.
# change filetype to .yaml if you want to use this as a GitHub Actions workflow.
# commit
# Every time an issue in your repository is opened or reopened, this workflow will add the labels that you specified to the issue.




name: Label issues
on:
  issues:
    types:
      - reopened
      - opened
jobs:
  label_issues:
    runs-on: ubuntu-latest
    permissions:
      issues: write
    steps:
      - run: gh issue edit "$NUMBER" --add-label "$LABELS"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # dont touch
          GH_REPO: ${{ github.repository }} # dont touch
          NUMBER: ${{ github.event.issue.number }} # dont touch
          LABELS: triage # EDIT THIS ONE, comma delim
