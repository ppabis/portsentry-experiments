#!/bin/bash

hostnamectl set-hostname blue-team

# Install portsentry
export DEBIAN_FRONTEND=noninteractive
apt update
apt install portsentry -y

# Install Docker
apt install ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
 | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl enable --now docker

# Script to block IPs via AWS Network ACL
apt install python3-boto3 -y
curl -L "https://raw.githubusercontent.com/ppabis/portsentry-experiments/refs/heads/main/block_via_nacl.py" -o /usr/local/bin/block_via_nacl.py
chmod +x /usr/local/bin/block_via_nacl.py
