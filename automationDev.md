# GH Issues automations (Actions, Workflows) dev notes

### Automations hierarchy: 

1. Repo > GH Actions
2. Project > Workflows

docs

- triggers https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#issues
  - issue... open, edit, delete
  - un/labeled
  - un/typed (e.g. Bug, Task, Feature,.... define Types in ORG settings) 


## automation ideas

1. Issue deletion

move issue to bucket (custom Field) 

append 'DELETE' Label

every ~49hr, delete all Issues with the 'DELETE' Label /Field


1. 
1. 
2.  




## cmd

```
# runs all commands 

gh issue create -t "YOURTITLE 1" -b BODYTEXT;  
gh issue create -t "YOURTITLE 2" -b " "; # creates issue with NO body text; must include space between quotes 
gh issue create -t "YOURTITLE 3" -b BODYTEXT;

```
