#### (L4V0: L4V repo #0)
 


## L4V Project planner

SETUP?: 
- build off the Kanban template
- try not to change defaults (to preserve prebuilt and documentation fxns) 
 



Repo lvl: 
- Labels, "at a glance"  badges
- triage (testing Action) 
- G.Ads
- G.Analytics
- G.Business
- G.SConsole
- Meta (FB+IG) 
Actions: 
- on issue commit within parent repo >> label "triage" + assign to alhllc 

Project lvl:
custom fields:
- Status: (defaults)
- L4V buckets: 
- Google
- Social media
- Emails
- documentation (databases?) 
Workflows: 
- on issue commit within [L4V repo] >> add to [Backlog] bucket 


How to remove "triage" label when Issue status exits [Backlog] bucket? (and do the reverse) 

```
On:
Issues:
Status: Triage  # find documentation for CLI triggers
... 
run: gh issue edit --add-label "Triage" 
 ???

```


----------------------------------


How automations work will determine the usecase for Labels
- automation ex: G.Ads label > Google bucket
- Labels = displayed in ~all views
- set as middle granularity? 1 below buckets: G.Ads, G.TagMgr, Meta (FB+IG), mobile website, Intaker, ...
- while buckets = google, website, social media, Marketing, emails, documentation,...
- then Milestones = campaigns with tasks from various buckets (fix g.ads = g.tags + g.analytics + g.search +...)

  
Automations (Repo Actions, Project Workflows):
- CLI commands (action.yml scripts; "THEN" actions) : https://cli.github.com/manual/gh_issue
- repo: add-to-Project actions, examples https://github.com/actions/add-to-project
- Actions repo https://github.com/actions
- triggers: https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-when-your-workflow-runs/triggering-a-workflow
- add label upon Issue commit: https://docs.github.com/en/actions/how-tos/use-cases-and-examples/project-management/adding-labels-to-issues#creating-the-workflow

automat ideas: 
- Project > (3 dots menu) > Workflows 
- has subs = add "parent" label
- created by me = assigned to me (default view of github.com/issues)
- sub issue = add "sub" label 
- parent into milestone = sub into milestone


----------------------------------

Repo: 
- Label
- Milestone
- Assignee
- GH Actions (automations)

Project
- custom fields
- premade Workflows (automations) 

Issues
- single units/tasks
- independent from Repo or Project
- however, must be assigned to a Repo upon creation
- thus, Issues always have Label/Milestone/Assignee of the parent Repo


Issues: 
- basic unit of Projects
- live independently from repos and projects
- Can apply the custom fields (labels, etc.) of the Repo or Project they are assigned to
1. (Parent) Issue = big task
2. (Sub) Issue = sub tasks 
   - create within OR add existing Issue to Parent
   - up to 100 sub-issues per issue
   - up to 8 levels of nested sub-issues



Milestones: (Repo > Issues or PR > Milestones )
- collection of Issues
- 


1. "Buckets": (Project > settings > custom fields > Single Select)
   1. Status = GH default

2. Label 
   1. REPO SPECIFIC > use the label on any issue, pull request, or discussion within that repo
   2. default Labels managed by org > https://docs.github.com/en/organizations/managing-organization-settings/managing-default-labels-for-repositories-in-your-organization
   3. Appears in Issues panel 




## GH Projects (Issues) dev

https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects
Hierarchy units

Board layout: 

- TOP layer (buckets) == (custom) "Options" within a (custom) "Field" 
  -   a Field is a collection of custom "Options" 
      -   Field type can be Single Select (custom string) or Iteration (custom time segment)
      -  bucket names can only come from one Field collection at a time
   -  Option = the custom field name  
      -  arbitrary string + color
      -  unlimited(?) Options (therefore buckets, categories, tags, etc.) can be added via settings 
      -  ex: Bug tracker = P0, P1, P2; Kanban = Status, Backlog, Ready, To Do...
   -  NOTES: duplicate Field collection to  

  - 
- 
- == view option > "Column By:" > [custom field] > ["Option"]
    -  field type: Single Select or Iteration
       -  Single Select = custom attribute
          -  Kanban: "Status"  Backlog, Ready, In Progress
          -  Bug tracker: "Priority" P0, P1, P2
       -  Iteration = custom time segment
    -  default == "Status": Backlog, Ready, In Progress etc
    -  Visible in group headers and value pickers





# L4V TO-DO LIST

### Tasks

1) create L4V Github Project planner  
   - up next: try /repo/Issues
   - upload plannerv2.md (see nLM)
   - start transcribing in order to learn/dev Issues 
   - once the setup is configured, use LLM to transcribe the remaining planner data 

Project/Issue units: 
- labels (bug, duplicate, etc.) 
- relationships (parent/sub issues)
- milestones
- status... (kanban's buckets: To Do, In Progress, Backlog) 
   - not an option when creating new Issues?
   - must assign to Project first; statuses are set at Project level
   - == any single select or iteration field

https://github.com/alhllc/L4V0/issues

L4V project setup: [custom board layout](https://docs.github.com/en/issues/planning-and-tracking-with-projects/customizing-views-in-your-project/customizing-the-board-layout)
- "Buckets"
  - topmost level
  - Single Select or Iteration Field
https://docs.github.com/en/issues
https://docs.github.com/en/issues/planning-and-tracking-with-projects/customizing-views-in-your-project/customizing-the-board-layout
https://docs.github.com/en/issues/tracking-your-work-with-issues/configuring-issues/quickstart


<br>
<br>

- https://docs.github.com/en/issues/guides
- https://github.com/marketplace
- https://github.com/marketplace/jira-software-github
- https://github.com/BankkRoll/repo2pdf .. 

<br>

### TASKS EXPANDED

1) <details open>
   <summary>L4V github project planner</summary>

   0) first try via /repo/Issues  
   1) Research GitHub Project custom fields  
   2) Build v1 GitHub Project in dedicated L4V repo  
   3) Manually enter starter tasks  
   4) Export project data (“Export view data”)  
   5) Design markdown-based database architecture  
   6) Write script to parse DB & auto-create GH issues  
   7) Build rapid-intake web GUI  > [issue templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/about-issue-and-pull-request-templates#issue-templates)
   8) Create LLM-agnostic submission method  
   9) Implement reverse sync (GH → DB)  
   10) Enable LLM read-only access for status reports
   11) [msft Teams integration!](https://github.com/integrations/microsoft-teams/blob/master/Readme.md) 

   <br> 

   <details>
   <summary>even more expanded</summary>
   
   
   
   1) **Research GitHub Project custom fields**  
      - Read official docs; note field types & limits  
      - Draft initial list of required custom fields  
      - **[Q1]** Specify any *must-have* fields/tags (e.g., **Priority**, **Status**, **LLM Ready**)
   
   2) **Build v1 GitHub Project in dedicated L4V repo**  
      - Create or select L4V repository  
      - Enable Projects, add custom fields/tags from Task 1  
      - **[Q2]** Use a brand-new repo or an existing one?
   
   3) **Manually enter starter tasks**  
      - Add ~5-8 varied issues to exercise every field  
      - Confirm fields render correctly in board views
   
   4) **Export project data**  
      - Use “Export view data” to download CSV/JSON  
      - Store export in project `/data/` folder for analysis
   
   5) **Design markdown-based database architecture**  
      - Map exported field names → cleaner camelCase keys  
      - Define controlled vocabularies (e.g., `status:` idea | backlog | in-progress | review | done)  
      - **[Q3]** Preferred file name and location for the DB (e.g., `project_db.md` in repo root)?
   
   6) **Write script to parse DB & create issues**  
      - Choose language (GitHub REST/GraphQL API)  
      - Parse markdown → JSON, POST to GitHub  
      - Handle updates vs. new items  
      - **[Q4]** Language preference: **Python**, **JavaScript/Node**, or other?
   
   7) **Build rapid-intake web GUI**  
      - Minimal form → writes to DB and/or GH API  
      - Consider Flask/FastAPI (Python) or Next.js (JS)  
      - Trigger backend script on submission  
      - **[Q5]** Any UI/tech-stack preferences?
   
   8) **Create LLM-agnostic submission method**  
      - Define plain-text syntax (e.g., `/add "Task" :: description :: labels`)  
      - Backend parses and enqueues creation workflow
   
   9) **Implement reverse sync (GH → DB)**  
      - Scheduled job or GitHub Action to append/merge changes back into DB  
      - Resolve conflicts (GH edits vs. DB edits)
   
   10) **Enable LLM read-only access for status reports**  
       - Host DB file in repo (public or token-scoped)  
       - Document retrieval URL or API endpoint for LLMs  
       - Optional: expose filtered JSON for easy parsing
   
   ---
   
   ### Clarifying Questions
   
   1. **[Q1]** Must-have custom fields/tags?  
   2. **[Q2]** New repo vs. existing L4V repo?  
   3. **[Q3]** Preferred database file name/location?  
   4. **[Q4]** Script language preference (Python/JS/other)?  
   5. **[Q5]** Front-end tech preference (Flask, Next.js, etc.)?
   
   </details>
   
   </details>


