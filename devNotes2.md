# devNotes pt 2


### Projects notes

Labels needed
- indicates a sub-issue (parent-issue displays [x/y] tag)
- STUCK
- NEEDS REPLY
- 

[Custom fields](https://github.com/orgs/alh-industries/projects/1/settings/fields/Status): 

- [Software]: Photoshop, Illustrator, LightRoom,  
- [Vendor]: SimpleLaw, Docusign, GoDaddy, Google, Intaker, Wix, Hostgator, MSFT, 
- [User Request]: Joe, Stella, Lindsay,
- [Partner]


[Custom Type](https://github.com/organizations/alh-industries/settings/issue-types): 
- an Issue custom tag/category/etc, repo agnostic 
- high level, higher than repo 
- what can be done with Type field? Slice? 
- try: LLM, 

Custom Proprty??? https://github.com/organizations/alh-industries/settings/custom-property/Custom-ALHProperty

#### Fields that appear in [view]
-  view: repo > Issues
   -  Label, [x/y] sub-Issues, Assignee, Estimate #, Milestone, Comments,
   -  Type: single choice (bug, feature, task). can it be customized? >> [org settings](https://github.com/organizations/alh-industries/settings/issue-types)!
      - use to indicate bug or task vs... documentaion? notes?
-  view: Issues button
-  <img width="876" height="725" alt="image" src="https://github.com/user-attachments/assets/8f7be898-6129-49d3-b6f1-93e0ff75453e" />

-  view: Projects> Bucket view
  -  All custom field in [Project settings](https://github.com/orgs/alh-industries/projects/1/settings)
  -
  -   <img width="358" height="468" alt="image" src="https://github.com/user-attachments/assets/a0f9fa21-f28b-4ca9-9a59-b1d343675fec" />
  -   <img width="904" height="386" alt="image" src="https://github.com/user-attachments/assets/1e7661a0-63a7-4e79-9d2c-ee62f9160800" />



### Automation shit: 

gh auth refresh -s project # add issue to Project...

OR 

gh issue create --title "
