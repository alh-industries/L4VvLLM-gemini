# Custom Issue Tags... (Type, Label, Field) 


Type: 
- Bug. subLabels: known solution, unknown solution,...
- AI
- SEO
- devOPS
- 

Labels: want to see these at-a-glance
- blocker... ex: "cannot do TASK due to no ADMIN"
- pending response... waiting for CLIENT response 
- CLIENT request vs JOE/Stella/Debbie request? ... 
- CRITICAL TO DO
- [platform] .. G.Ads, G.TagMgr,...


example tag setups 
- https://forum.openrefine.org/t/cleaning-up-our-github-issue-labels/755/23
- https://docs.google.com/document/d/19LLxQxQNgELxSuxT8nwgoWEHMdlGjjnJO20zFsZpLak/edit?tab=t.0
- https://docs.google.com/spreadsheets/d/1pbZ2ZsNq5cRCn2JhTT_HNUK7PreWumqD/edit?gid=926178593#gid=926178593
- https://robinpowered.com/blog/best-practice-system-for-organizing-and-tagging-github-issues
- https://imgur.com/XnKDC76
- https://github.com/alh-industries/L4V-ORGv1/labels



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
