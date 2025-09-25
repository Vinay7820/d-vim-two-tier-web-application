#!/usr/bin/env bash
set -e


# This installs an older MongoDB version (example: 4.0). Modify as needed.
# NOTE: this is intentionally old/outdated.


# Update and install requirements
apt-get update
apt-get -y upgrade
apt-get -y install gnupg wget curl python3-pip


# Add MongoDB repo for an older release (example uses Ubuntu 18.04 + mongodb 4.0)
apt-get install -y software-properties-common
wget -qO - https://www.mongodb.org/static/pgp/server-4.0.asc | apt-key add -
add-apt-repository 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse'
apt-get update
apt-get -y install mongodb-org


# Configure mongod to bind to private IP only (the Terraform will set network and SGs)
cat > /etc/mongod.conf <<EOF
# mongod.conf
net:
port: 27017
bindIp: 0.0.0.0
security:
authorization: "enabled"
EOF


systemctl enable mongod
systemctl restart mongod


# Create admin user
mongo <<EOF
use admin
db.createUser({user: "admin", pwd: "AdminPass123!", roles:[{role: "root", db: "admin"}]})
EOF


# Create application user
mongo admin -u admin -p AdminPass123! <<EOF
use tasky
db.createUser({user: "taskyuser", pwd: "taskypass", roles:[{role: "readWrite", db: "tasky"}]})
EOF


# Install AWS CLI for backup script (if using AWS).
apt-get -y install awscli


# Setup cron job to run backup_to_bucket.sh every day at 03:00
chmod +x /opt/backup_to_bucket.sh
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/backup_to_bucket.sh >> /var/log/backup.log 2>&1") | crontab -
