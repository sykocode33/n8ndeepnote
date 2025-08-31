#!/bin/bash
set -e

echo "🔄 Updating system..."
apt update && apt upgrade -y

echo "📦 Installing dependencies..."
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release wget unzip

echo "🐳 Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "📂 Setting up n8n with Docker Compose..."
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

docker compose up -d

echo "☁️ Installing Cloudflare Tunnel..."
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb || apt --fix-broken install -y

echo "🚀 Starting Cloudflare Tunnel..."
cloudflared tunnel --url http://localhost:5678 --no-autoupdate
