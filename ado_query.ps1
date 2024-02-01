# Define your Personal Access Token
$pat = "YOUR-PAT-HERE"

# Define the organization
$organization = "YOUR-ORG-HERE"

# Define the API URL
$apiUrl = "https://dev.azure.com/$organization/_apis/projects?api-version=6.0"

# Create the Authorization header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

# Create the headers for the API request
$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

# Make the API request and save the response in a variable
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# The list of projects is in the 'value' property of the response
$projects = $response.value

# Output the list of projects
$projects

# ...

# Create an empty array to hold the project and repository data
$projectsWithRepos = @()

# Loop over each project
# ...

# Loop over each project
# foreach ($project in $projects) {
#     # Define the API URL for the repositories
#     $repoApiUrl = "https://dev.azure.com/$organization/$($project.name)/_apis/git/repositories?api-version=6.0"

#     # Make the API request and save the response in a variable
#     $repoResponse = Invoke-RestMethod -Uri $repoApiUrl -Headers $headers -Method Get

#     # The list of repositories is in the 'value' property of the response
#     $repos = $repoResponse.value

#     # Loop over each repository
#     foreach ($repo in $repos) {
#         # Create a new object that includes only the desired properties
#         $repoObj = New-Object PSObject -Property @{
#             RepositoryName = $repo.name
#             RepositoryID   = $repo.id
#             ProjectName    = $repo.project.name            
#             url            = $repo.url            
#             RepoSize       = $repo.size
#             remoteUrl      = $repo.remoteUrl
#             isDisabled     = $repo.isDisabled
#         }

#         # Add the repository object to the array
#         $projectsWithRepos += $repoObj
#     }
# }

foreach ($project in $projects) {
    # Define the API URL for the repositories
    $repoApiUrl = "https://dev.azure.com/$organization/$($project.name)/_apis/git/repositories?api-version=6.0"

    # Make the API request and save the response in a variable
    $repoResponse = Invoke-RestMethod -Uri $repoApiUrl -Headers $headers -Method Get

    # The list of repositories is in the 'value' property of the response
    $repos = $repoResponse.value

    # Loop over each repository
    foreach ($repo in $repos) {
        # Create a new object that includes only the desired properties
        $repoObj = [PSCustomObject]@{
            RepositoryName = $repo.name
            ProjectName    = $repo.project.name
            RepositoryID   = $repo.id
            RepoSize       = $repo.size
            URL            = $repo.url
            isDisabled     = $repo.isDisabled
            remoteUrl      = $repo.remoteUrl
        }

        # Add the repository object to the array
        $projectsWithRepos += $repoObj
    }
}

# ...

# Export the data to the CSV file
$projectsWithRepos | Export-Csv -Path $csvPath -NoTypeInformation

# Output the list of projects with their repositories
$projectsWithRepos

# Define the path to the CSV file in the Documents folder
# ...

# Define the path to the CSV file in the Documents folder
$csvPath = "$([Environment]::GetFolderPath('MyDocuments'))\projectsWithRepos.csv"

# Check if the CSV file already exists
if (Test-Path $csvPath) {
    # The CSV file exists, so rename it
    $oldCsvPath = "$([Environment]::GetFolderPath('MyDocuments'))\projectsWithRepos_old.csv"
    Rename-Item -Path $csvPath -NewName $oldCsvPath
}

# Export the data to the new CSV file
$projectsWithRepos | Export-Csv -Path $csvPath -NoTypeInformation