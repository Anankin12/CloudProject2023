# PowerShell script to delete multiple Nextcloud users via Docker in parallel

# Define base user name
$baseUserName = "locust_user"

# Define the total number of users to delete
$totalUsers = 30

# ScriptBlock that contains the code to delete a single user
$scriptBlock = {
    param($userName)
    
    # Command to delete the user in the Nextcloud instance
    $cmd = "docker exec --user www-data nextcloud_instance php /var/www/html/occ user:delete $userName"

    Invoke-Expression $cmd

    # Output the user name to the console
    Write-Host "Deleted user: $userName"
}

# Loop to delete each user
for ($i = 0; $i -lt $totalUsers; $i++) {
    # Construct the user name
    $userName = "$baseUserName$i"

    # Start the job in the background
    Start-Job -ScriptBlock $scriptBlock -ArgumentList $userName
}

# Wait for all jobs to complete
Get-Job | Wait-Job

# Display the results of the jobs
Get-Job | Receive-Job

# Clean up the jobs
Get-Job | Remove-Job
