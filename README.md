# ado-audit-scripts

## GH Repo Audit

### Requirements
Set Environment Variables:
- ```$env:PAT = "my_personal_access_token"```
- ```$env:ORGANIZATION = "my_organization_name"```

### Script CSV Export Information
- [X] Repo Path
- [X] Repo Creation Date
- [X] Repo last update date
- [X] Organization
- [X] Teams associated
- [ ] Main Repo contacts
- [X] Project Team
- [X] Repo Visibility
- [X] GHAS Active
- [X] Actions on Repo
- [ ] Packages
- [X] Repo Size
- [X] LFS Size
- [X] Total Size
- [X] Secrets - Working at Repo level. As of 2/1/2024, the "List repository environments" endpoint is a preview feature and might not work as expected.
- [X] Dependabot

## GH User Audit
### Requirements
Set Environment Variables:
- ```$env:PAT = "my_personal_access_token"```
- ```$env:ENTERPRISE = "my_enterprise_name"```

### Script CSV Export Information ###

- [X] Username
- [X] Name
- [X] E-mail Address
- [X] License Type (VS or GH)
- [X] Account Creation Date
- [X] Last Login Date - *__Note: Unavailable via API, use Last Activity Date instead__*
- [X] Last Activity Date
- [X] Org. Memberships
- [X] Team Memberships - *__Note: May be affected by org permissions if querying a user account on public GitHub.com__*
- [ ] Copilot License
- [ ] GHAS License


