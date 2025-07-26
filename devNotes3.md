# devNotes pt3

IMPORTANT: 

- automation triggers / actions help define custom Type/Label/Field and their interactions
  - e.g. can setting Type > apply Labels?  

Type
- allows Users to see all Issues of that Type across all Repos/Projects/Clients/etc
- ex: [Bug, Task, Feature], AI/LLM, CRITICAL, Stalled, Broken, Client Request, Info,...
  
When quick-creating new Issue

User essentially defines:
- Type - single - MAJOR hierarchy
- Labels - multi - (defined by repo(s) the Issue is attached to)


- Project>Issues>create: 
- Title - string
- Body - string
- Assignee - choose multiple
- Label - Choose multiple
  - defined manually
  - defined by Template
  - defined via Action/Workflow
- Type - CHOOSE 1
- projects - (auto defined)
- Milestone - CHOOSE 1
