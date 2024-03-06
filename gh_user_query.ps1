# Get the personal access token and organization from environment variables
$pat = [System.Environment]::GetEnvironmentVariable('PAT')

$enterprise = [System.Environment]::GetEnvironmentVariable('ENTERPRISE')
# Get the organization from the environment variable
#$organization = [System.Environment]::GetEnvironmentVariable('ORGANIZATION2')

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
    "Accept"        = "application/vnd.github.v3+json"
}

try {
    #$response = Invoke-RestMethod -Uri "https://api.github.com/enterprises/$enterprise/users" -Headers $headers
    #$response = Invoke-RestMethod -Uri "https://api.github.com/orgs/$organization/members" -Headers $headers
    $response = Invoke-RestMethod -Uri "https://api.github.com/enterprises/$enterprise/consumed-licenses" -Headers $headers
    # Expand the 'users' property
    $expandedResponse = $response | Select-Object -ExpandProperty users | ForEach-Object {
        write-host "I've found a username for $($_.github_com_login)!"
        # Get the user's events
        $events = Invoke-RestMethod -Uri "https://api.github.com/users/$($_.github_com_login)" -Headers $headers
        $lastActivity = Invoke-RestMethod -Uri "https://api.github.com/users/$($_.github_com_login)/events" -Headers $headers
        $lastActivityTime = $lastActivity | Sort-Object created_at -Descending | Select-Object -First 1 -ExpandProperty created_at

        # Remove newline characters from the properties
        $_.github_com_login = $_.github_com_login -replace "`n", ""
        $_.github_com_name = $_.github_com_name -replace "`n", ""
        $_.visual_studio_subscription_user = $_.visual_studio_subscription_user -replace "`n", ""
        $_.license_type = $_.license_type -replace "`n", ""
        $_.github_com_profile = $_.github_com_profile -replace "`n", ""
        $_.github_com_enterprise_roles = $_.github_com_enterprise_roles -replace "`n", ""
        $_.github_com_member_roles = $_.github_com_member_roles -replace "`n", ""
        $_.github_com_verified_domain_emails = $_.github_com_verified_domain_emails -replace "`n", ""
        $_.github_com_saml_name_id = $_.github_com_saml_name_id -replace "`n", ""
        $_.github_com_orgs_with_pending_invites = $_.github_com_orgs_with_pending_invites -replace "`n", ""
        $_.github_com_two_factor_auth = $_.github_com_two_factor_auth -replace "`n", ""
        $_.visual_studio_license_status = $_.visual_studio_license_status -replace "`n", ""
        $_.visual_studio_subscription_email = $_.visual_studio_subscription_email -replace "`n", ""


        $_ | Select-Object github_com_login,
        github_com_name,
        github_com_user,        
        visual_studio_subscription_user,
        license_type, 
        github_com_profile, 
        @{Name = 'Account Creation Date'; Expression = { $events | Select-Object -ExpandProperty created_at } },
        @{Name = 'Last Activity'; Expression = { $lastActivityTime } },
        @{Name = 'Enterprise Roles'; Expression = { $_.github_com_enterprise_roles } },
        @{Name = 'Member Roles'; Expression = { $_.github_com_member_roles } },
        @{Name = 'Verified Domain E-Mails'; Expression = { $_.github_com_verified_domain_emails } },
        github_com_saml_name_id,
        @{Name = 'Pending Invites'; Expression = { $_.github_com_orgs_with_pending_invites } },
        github_com_two_factor_auth,
        @{Name = 'VS License Status'; Expression = { $_.visual_studio_license_status } },
        @{Name = 'VS Subscription E-mail'; Expression = { $_.visual_studio_subscription_email } }        
    }     
      
}
catch {
    Write-Host "Error: $_"
    exit 1
}


# Get the path to the user's My Documents folder
$myDocuments = [Environment]::GetFolderPath("MyDocuments")

# Define the path to the CSV file

$csvFile = "$myDocuments\github_users_${enterprise}_output.csv"


# Check if the CSV file already exists
if (Test-Path $csvFile) {
    # Get the current date and time
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"

    # Define the path to the old CSV file
    $oldCsvFile = "$myDocuments\github_users_${organization}_output_old_$timestamp.csv"

    # Rename the CSV file
    Rename-Item -Path $csvFile -NewName $oldCsvFile
}

# Create the CSV file
#$response | Export-Csv -Path $csvFile -NoTypeInformation
$expandedResponse | Export-Csv -Path "$myDocuments\github_${enterprise}_output.csv" -NoTypeInformation