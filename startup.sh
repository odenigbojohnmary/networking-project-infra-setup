#!/bin/bash
set -euo pipefail

# Update package index
apt-get update -y

# Install prerequisites
apt-get install -y ca-certificates curl gnupg lsb-release

. /etc/os-release
DISTRO_ID="${ID}"            # e.g. ubuntu, debian
DISTRO_CODENAME="${VERSION_CODENAME}"

case "${DISTRO_ID}" in
  ubuntu)
    DOCKER_REPO_PATH="ubuntu"
    ;;
  debian)
    DOCKER_REPO_PATH="debian"
    ;;
  *)
    echo "Unsupported distro: ${DISTRO_ID}" >&2
    exit 1
    ;;
esac

# --- Install Docker (official repo) ---
install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/${DOCKER_REPO_PATH}/gpg" -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${DOCKER_REPO_PATH} \
  ${DISTRO_CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

# --- Install Nginx ---
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx


echo "Docker and Nginx installation complete." > /var/log/startup-script.log