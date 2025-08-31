#!/bin/bash
set -e
apt update && apt upgrade -y
apt install -y docker.io docker-compose wget curl
mkdir -p ~/n8n-docker && cd ~/n8n-docker
cat > docker-compose.yml <<EOL
version: "3.1"
services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    volumes:
      - ./n8n_data:/home/node/.n8n
EOL
docker-compose up -d
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb || apt --fix-broken install -y
cloudflared tunnel --url http://localhost:5678 --no-autoupdate
