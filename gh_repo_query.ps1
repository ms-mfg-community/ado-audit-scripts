# Get the personal access token and organization from environment variables
$pat = [System.Environment]::GetEnvironmentVariable('PAT')
$organization = [System.Environment]::GetEnvironmentVariable('ORGANIZATION')

# Define your GitHub Personal Access Token
#$pat = "your_pat_here"

# Define the organization
#$organization = "ms-mfg-community"

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
    # Define the API URL for the secrets of the current repository
    $secretsApiUrl = "$baseApiUrl/$($_.owner.login)/$($_.name)/actions/secrets"
    # Define the API URL for the environments of the current repository
    $environmentsApiUrl = "$baseApiUrl/$($_.owner.login)/$($_.name)/environments"

    # Initialize the hasActions variable to False
    $hasActions = $false
    # Initialize the hasSecrets variable to False
    $hasSecrets = $false
    # Initialize the environments variable to an empty array
    $environments = @()

    # Make the API request and save the response in a variable
    try {
        $workflowResponse = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get -ErrorAction Stop

        # Check if the response contains any workflows
        $hasActions = $workflowResponse.Count -gt 0
    }
    catch {
        # An error occurred, so leave hasActions as False
    }

    # Make the API request and save the response in a variable
    try {
        $secretsResponse = Invoke-RestMethod -Uri $secretsApiUrl -Headers $headers -Method Get -ErrorAction Stop

        # Check if the response contains any secrets
        $hasSecrets = $secretsResponse.secrets.Count -gt 0
    }
    catch {
        # An error occurred, so leave hasSecrets as False
    }

    try {
        $environmentsResponse = Invoke-RestMethod -Uri $environmentsApiUrl -Headers $headers -Method Get -ErrorAction Stop

        # Check if the response contains any environments
        if ($environmentsResponse.environments.Count -gt 0) {
            $environments = $environmentsResponse.environments | ForEach-Object { $_.name } -join ', '
        }
    }
    catch {
        # An error occurred, so leave environments as an empty array
    }

    # Define the API URL for the teams of the current repository
    $teamsApiUrl = "$baseApiUrl/$($_.owner.login)/$($_.name)/teams"

    # Make the API request and save the response in a variable
    $teamsResponse = Invoke-RestMethod -Uri $teamsApiUrl -Headers $headers -Method Get
    # Create a string that contains the names of the teams and their permissions


    # Create a string that contains the names of the teams and their permissions
    $teams = ($teamsResponse | ForEach-Object { "$($_.name):$($_.permission)" }) -join ', '

    # Select the desired properties and add the new properties
    $_ | Select-Object id,node_id,name,full_name,private,created_at,updated_at,pushed_at,git_url,clone_url,size,has_issues,has_projects,has_downloads,has_wiki,has_pages,has_discussions,forks_count,mirror_url,archived,disabled,open_issues_count,license,allow_forking,is_template,web_commit_signoff_required,topics,visibility,forks,open_issues,watchers,default_branch,permissions,
        @{Name='Advanced_Security'; Expression={$_.security_and_analysis.advanced_security}},
        @{Name='secret_scanning'; Expression={$_.security_and_analysis.secret_scanning}},
        @{Name='secret_scanning_push_protection'; Expression={$_.security_and_analysis.secret_scanning_push_protection}},
        @{Name='dependabot_security_updates'; Expression={$_.security_and_analysis.dependabot_security_updates}},
        @{Name='secret_scanning_validity_checks'; Expression={$_.security_and_analysis.secret_scanning_validity_checks}},
        @{Name='HasActions'; Expression={$hasActions}},
        @{Name='Teams'; Expression={$teams}},
        @{Name='HasSecrets'; Expression={$hasSecrets}},
        @{Name='Environments'; Expression={$environments}}
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