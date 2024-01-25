# ado-audit-scripts

## pre-requisites

- Create an ADO Personal Access Token scope to the organization you are scanning
- Run script locally

```
$pat = "YOUR-PAT-HERE"

# Define the organization
$organization = "YOUR-ORG-HERE"
```

These should look like the following

```
$pat = "1234asdfjkl5678"

# Define the organization
$organization = "My-Org-123"
```

Output should look like this:

![image](https://github.com/ms-mfg-community/ado-audit-scripts/assets/78826051/7c197917-ea54-42a6-a4f7-a87e4c824baf)


# issues

Logic hasn't been fully baked for replacing the ```_old``` csv file
