# keep custom
# gh label list --json name -q '.[].name' | grep -v -x -F -f <(printf "%s\n" "bug" "documentation" "duplicate" "enhancement" "good first issue" "help wanted" "invalid" "question" "wontfix") | xargs -I {} gh label delete "{}" --yes

# delete ALL repo Labels
# gh label list --json name -q '.[].name' | xargs -I {} gh label delete "{}" --yes

# delete first 1000 labels
# gh label list --limit 1000 --json name -q '.[].name' | xargs -I {} gh label delete "{}" --yes


# delete all labels, incl special chars
# gh label list --limit 1000 --json name | jq -r '.[].name' | xargs -I {} gh label delete "{}" --yes

# no jq, no xargs
gh label list --limit 1000 --json name -q '.[].name' | while read -r label; do gh label delete "$label" --yes; done
echo "Press [Enter] to close the terminal."
read