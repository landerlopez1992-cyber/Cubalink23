#!/bin/bash
cd "$(dirname "$0")"
echo "Iniciando Cloudflare Tunnel..."
echo "Descargando cloudflared..."
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-arm64 -o cloudflared
chmod +x cloudflared
echo "Configurando túnel..."
./cloudflared tunnel login
./cloudflared tunnel create cubalink-backend
./cloudflared tunnel route dns cubalink-backend backend.cubalink23.com
echo "Iniciando túnel..."
./cloudflared tunnel run cubalink-backend
