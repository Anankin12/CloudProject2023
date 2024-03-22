# Cloud Storage System Deployment Guide

This guide outlines the deployment of a cloud storage system using Docker. It leverages Nextcloud for file storage, MySQL for the database, Redis for caching, Nginx for load balancing, and Locust for load testing.

## Prerequisites

Docker and Docker Compose installed on your machine.
Basic understanding of Docker, Docker Compose, and YAML syntax.

## Initial Setup

### Clone the Repository

Start by cloning the repository containing the `docker-compose.yml` and other necessary configuration files.

### Prepare the Environment

Create the required directories as specified in the `docker-compose.yml` file for database data, Nextcloud data, and configurations.

### Modify docker-compose.yml (First Boot)

For the first boot, focus on setting up the MySQL database and the initial Nextcloud instance. Locate the `nextcloud_instance1` service in the `docker-compose.yml` file and comment it out. This step ensures a smooth MySQL setup phase.

### Modify Nginx Configuration (First Boot)

Before proceeding to enable the second Nextcloud instance, review and possibly comment out parts of the `nginx.conf` file that reference `nextcloud_instance1` to avoid any conflicts or issues during the first run.

### Set Environment Variables

Update the `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, and `MYSQL_PASSWORD` in the docker-compose file to your desired settings.

## Deployment Steps

### Deploy the System

Run `docker-compose up -d` to start the MySQL, Redis, the first Nextcloud instance, and the Nginx container.

### Initial Nextcloud Setup

Access Nextcloud in a web browser at `http://localhost:8080` and follow the setup instructions for the MySQL database installation.  

### Configure Nextcloud (Optional)

Customize additional Nextcloud settings as needed through its UI or CLI. It can be also done later, but it`s better to do it now for compatibility reasons.

### Stop the System

After setup completion and verification, use `docker-compose down` to stop all containers.

### Enable the Second Nextcloud Instance

Uncomment the `nextcloud_instance1` service in `docker-compose.yml`and `nginx/conf` to include it in the setup.

### Rerun Docker Compose

Execute `docker-compose up -d` again to start all services, including the second Nextcloud instance.

## Post-Deployment Steps

### Accessing Nextcloud

The Nextcloud UI is accessible at `http://localhost` with Nginx managing load balancing. 

### Security Configuration and System Commands (Optional to run load testing)

These steps must be executed if and only if you want to run locust for load balancing, as they disable important security measeures that will prevent Locust from properly running but that are essential for deployment.

```shell
# Set trusted domains for Nextcloud instances to allow connections
docker exec --user www-data nextcloud_instance php /var/www/html/occ config:system:set trusted_domains 2 --value=nextcloud_instance
docker exec --user www-data nextcloud_instance1 php /var/www/html/occ config:system:set trusted_domains 2 --value=nextcloud_instance1
docker exec --user www-data nextcloud_instance php /var/www/html/occ config:system:set trusted_domains 3 --value=nextcloud_nginx
docker exec --user www-data nextcloud_instance1 php /var/www/html/occ config:system:set trusted_domains 3 --value=nextcloud_nginx

# Disable rate limiting and file locking for load testing
docker exec --user www-data nextcloud_instance php /var/www/html/occ config:system:set ratelimit.protection.enabled --value=false
docker exec --user www-data nextcloud_instance1 php /var/www/html/occ config:system:set ratelimit.protection.enabled --value=false
docker exec --user www-data nextcloud_instance php /var/www/html/occ config:system:set filelocking.enabled --value=false
docker exec --user www-data nextcloud_instance1 php /var/www/html/occ config:system:set filelocking.enabled --value=false
```

Remember to re-enable the safety measures and to deactivate the exceptions after you're done testing.

#### Generate the test users

To properly run the load testing script, it is necessary to have the correct number of users with the correct usernames and passwords. Run the provided `powershell` script named `CreateTestUsersParallel.ps1`.  

For cleanup and/or troubleshooting in case the filenames result as already existing, run `DeleteTestUsersParallel.ps1`, which will delete all the userse generated with the other script and their data.  

#### Load Testing with Locust

For load testing, navigate to `http://localhost:8089` and start Locust load testing as described. Edit the `locustfile.py` to customize the tasks to run.
