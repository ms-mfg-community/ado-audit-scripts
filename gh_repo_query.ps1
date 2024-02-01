# Define your GitHub Personal Access Token
$pat = "{PAT}}"

# Define the organization
$organization = "{ORG}"

# Define the API URL
$apiUrl = "https://api.github.com/orgs/$organization/repos"

# Create the Authorization header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

# Create the headers for the API request
$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

$baseApiUrl = "https://api.github.com/repos"

# The list of repositories is in the response
$repositories = $response | ForEach-Object {
    # Define the API URL for the workflows directory of the current repository
    $apiUrl = "$baseApiUrl/$($_.owner.login)/$($_.name)/contents/.github/workflows"

    # Initialize the hasActions variable to False
    $hasActions = $false

    # Make the API request and save the response in a variable
    try {
        $workflowResponse = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get -ErrorAction Stop

        # Check if the response contains any workflows
        $hasActions = $workflowResponse.Count -gt 0
    }
    catch {
        # An error occurred, so leave hasActions as False
    }

    # Select the desired properties and add the new property
    $_ | Select-Object id,node_id,name,full_name,private,created_at,updated_at,pushed_at,git_url,clone_url,size,has_issues,has_projects,has_downloads,has_wiki,has_pages,has_discussions,forks_count,mirror_url,archived,disabled,open_issues_count,license,allow_forking,is_template,web_commit_signoff_required,topics,visibility,forks,open_issues,watchers,default_branch,permissions,
        @{Name='Advanced_Security'; Expression={$_.security_and_analysis.advanced_security}},
        @{Name='secret_scanning'; Expression={$_.security_and_analysis.secret_scanning}},
        @{Name='secret_scanning_push_protection'; Expression={$_.security_and_analysis.secret_scanning_push_protection}},
        @{Name='dependabot_security_updates'; Expression={$_.security_and_analysis.dependabot_security_updates}},
        @{Name='secret_scanning_validity_checks'; Expression={$_.security_and_analysis.secret_scanning_validity_checks}},
        @{Name='HasActions'; Expression={$hasActions}}
}

# Define the path to the CSV file in the Documents folder
$csvPath = "$([Environment]::GetFolderPath('MyDocuments'))\github_${organization}_output.csv"

# Check if the CSV file already exists
if (Test-Path $csvPath) {
    # The CSV file exists, so delete it
    Remove-Item -Path $csvPath
}

# Export the data to the new CSV file
$repositories | Export-Csv -Path $csvPath -NoTypeInformation