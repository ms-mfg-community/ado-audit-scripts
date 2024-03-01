# Get the personal access token and organization from environment variables
$pat = [System.Environment]::GetEnvironmentVariable('PAT')
#$organization = [System.Environment]::GetEnvironmentVariable('ORGANIZATION')
$enterprise = [System.Environment]::GetEnvironmentVariable('ENTERPRISE')

# Define your GitHub Personal Access Token
#$pat = "your_pat_here"

# Define the organization
#$organization = "ms-mfg-community"

# Replace these with your own values
# $enterprise = "your_enterprise"
# $token = "your_token"

# Set the headers for the API request
$headers = @{
    "Authorization" = "token $pat"
    "Accept" = "application/vnd.github.v3+json"
}

# Send the API request
$response = Invoke-RestMethod -Uri "https://api.github.com/enterprises/$enterprise/users" -Headers $headers

# Get the path to the user's My Documents folder
$myDocuments = [Environment]::GetFolderPath("MyDocuments")

# Create the CSV file
$response | Export-Csv -Path "$myDocuments\github_${enterprise}_output.csv" -NoTypeInformation