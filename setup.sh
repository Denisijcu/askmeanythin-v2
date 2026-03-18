#!/bin/bash
# HTB Machine: AskMeAnything - Realistic Edition
set -e

echo "============================================"
echo "  HTB AskMeAnything v2.0 - Realistic Edition"
echo "  Multi-stage: Web → LLM → SSH → Privesc"
echo "============================================"

# Dependencies
if ! command -v docker &>/dev/null; then
    echo "[!] Docker required. Install: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

echo "[*] Building realistic AskMeAnything Corp portal..."
docker build -t htb-askmeanything .

echo "[*] Starting on port 1337..."
docker run -d \
    --name htb-askmeanything \
    -p 1337:5000 \
    -e FLAG="HTB{askm34nyth1ng_r34l1st1c_v2_4ppr0v3d}" \
    htb-askmeanything

echo "[+] Portal UP: http://localhost:1337"
sleep 3

echo ""
echo "[*] Enumeration tests:"
echo "1. robots.txt:"
curl -s http://localhost:1337/robots.txt | cat
echo ""
echo "2. Internal status:"
curl -s http://localhost:1337/internal/status | python3 -m json.tool
echo ""
echo "3. Backup leak:"
curl -s http://localhost:1337/static/backups/app.conf.bak
echo ""
echo "============================================"
echo "  Attack path ready!"
echo "  • Guest Portal: http://localhost:1337"
echo "  • LM Studio: localhost:1234 (host)"
echo "============================================"
echo "Stop: docker stop htb-askmeanything"
echo "Logs: docker logs htb-askmeanything"
