# PowerShell script to create multiple Nextcloud users via Docker in parallel

# Define base user name
$baseUserName = "locust_user"

# Define password to be used for all users
$password = "test_password1234!"

# Define the total number of users to create
$totalUsers = 30

# ScriptBlock for creating a single user
$scriptBlock = {
    param($userName, $password)
    
    # Command to create the user in the Nextcloud instance
    $cmd = "docker exec -e OC_PASS=$password --user www-data nextcloud_instance /var/www/html/occ user:add --password-from-env $userName"
    Invoke-Expression $cmd

    # Output the user name to the console
    Write-Host "Created user: $userName"
}

# Loop to create each user
for ($i = 0; $i -lt $totalUsers; $i++) {
    # Construct the user name
    $userName = "$baseUserName$i"

    # Start the job in the background
    Start-Job -ScriptBlock $scriptBlock -ArgumentList $userName, $password
}

# Wait for all jobs to complete
Get-Job | Wait-Job

# Display the results of the jobs
Get-Job | Receive-Job

# Clean up the jobs
Get-Job | Remove-Job
