
```
{{}}

gh issue create -t TITLE -b BODY; 
gh issue create -t "{{$TITLE}}" -b "{{$BODY}}";



excel:

textjoin to combine cells into single string
=TEXTJOIN("+",TRUE,D26:F26)


= "gh issue create -t """&B10&""" -b """&C10&""";"

try..

= "gh issue create -t """&B10&""" -b """&C10&D10&E10""";"


```

Two source planners:

L4V Planner v0.0 / v1.0 (originally "[L4V Active Planner]"

L4V Planner v2.0 (originally "25Q3 - L4V planner v2.0")
- planner v2.6: full list of concatenated GH ISSUE commands