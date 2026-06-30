#!/bin/bash
set -euo pipefail

# Update package index
apt-get update -y

# Install prerequisites
apt-get install -y ca-certificates curl gnupg lsb-release

# --- Install Docker (official repo) ---
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

# --- Install Nginx ---
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx


echo "Docker and Nginx installation complete." > /var/log/startup-script.log