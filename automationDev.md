# GH Issues automations (Actions, Workflows) dev notes

### Automations hierarchy: 

1. Repo > GH Actions
2. Project > Workflows


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
