### (L4V0: L4V repo #0)


# L4V TO-DO LIST

### Tasks

1) create L4V Github Project planner  
   - current step: research GH Project custom fields  


## TASKS EXPANDED

### 1) L4V github project planner 

<details>

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
