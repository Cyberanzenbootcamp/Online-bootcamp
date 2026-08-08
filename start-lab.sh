#!/usr/bin/env bash
set -euo pipefail

# Custom CyberAnzen Colors
GREEN='\033[0;32m'
CYAN='\033[1;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}"
echo "  ____      _                 _                     "
echo " / ___|   _| |__   ___ _ __  / \   _ __  ____ ___ _ __ "
echo "| |  | | | | '_ \ / _ \ '__|/ _ \ | '_ \|_  / _ \ '_ \\"
echo "| |__| |_| | |_) |  __/ |  / ___ \| | | |/ /  __/ | | |"
echo " \____\__, |_.__/ \___|_| /_/   \_\_| |_/___\___|_| |_|"
echo "      |___/                                             "
echo -e "${NC}"
echo -e "${CYAN}>>> Initializing Class 1: Networking & Linux OS...${NC}\n"

# ==========================================
# 1. CLEANUP & IDLE MONITOR
# ==========================================
cleanup() {
    local exit_code=$?
    echo -e "\n${YELLOW}[*] Securing environment and destroying lab resources...${NC}"
    kill $(jobs -p) 2>/dev/null || true
    pkill -f cloudflared 2>/dev/null || true
    docker rm -f cyber-lab > /dev/null 2>&1 || true
    echo -e "${GREEN}✅ Lab wiped successfully. Goodbye!${NC}"
    exit "$exit_code"
}
trap cleanup EXIT SIGINT SIGTERM

monitor_idle() {
    local IDLE_TIME=0
    while true; do
        sleep 60
        CPU_LOAD=$(docker stats cyber-lab --no-stream --format "{{.CPUPerc}}" 2>/dev/null | sed 's/%//')
        IS_IDLE=$(echo "$CPU_LOAD" | awk '{if ($1 < 2.0) print 1; else print 0}')
        
        if [ "$IS_IDLE" -eq 1 ]; then
            IDLE_TIME=$((IDLE_TIME + 60))
            if [ "$IDLE_TIME" -ge 900 ]; then
                echo -e "\n\n${RED}⏰ [TIMEOUT] 15 Minutes Idle. Terminating lab to save quota!${NC}"
                kill -SIGTERM $$
                break
            fi
        else
            IDLE_TIME=0
        fi
    done
}

# ==========================================
# 2. DEPLOYMENT & TOOL INJECTION
# ==========================================
if docker ps -aq -f name=cyber-lab > /dev/null 2>&1; then
    docker rm -f cyber-lab > /dev/null 2>&1
fi

echo -e "${GREEN}[*] Booting core operating system...${NC}"
docker run -d --name cyber-lab -p 8080:6901 -e VNC_PW=Bootcamp2026! --privileged kasmweb/desktop:1.15.0 > /dev/null
sleep 10

echo -e "${GREEN}[*] Injecting CyberAnzen Networking Toolkit...${NC}"
docker exec -u 0 cyber-lab bash -c "
    rm -f /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nmap tcpdump net-tools dnsutils iputils-ping sudo > /dev/null 2>&1 && \
    usermod -aG sudo kasm-user && \
    echo 'kasm-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
"

# ==========================================
# 3. TUNNEL ESTABLISHMENT
# ==========================================
if ! command -v cloudflared > /dev/null 2>&1; then
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb > /dev/null 2>&1
    rm cloudflared-linux-amd64.deb
fi

echo -e "${GREEN}[*] Securing external connection via Cloudflare...${NC}"
pkill -f cloudflared 2>/dev/null || true
> cloudflare-lab.log
nohup cloudflared tunnel --url https://localhost:8080 --no-tls-verify > cloudflare-lab.log 2>&1 &

TUNNEL_URL=""
for i in {1..15}; do
    TUNNEL_URL=$(grep -aEo 'https://[a-zA-Z0-9-]+\.trycloudflare\.com' cloudflare-lab.log | head -n 1 || true)
    if [ -n "$TUNNEL_URL" ]; then break; fi
    sleep 2
done

# ==========================================
# 4. HANDOFF
# ==========================================
if [ -z "$TUNNEL_URL" ]; then
    echo -e "${RED}\n⚠️ ERROR: Network routing failed.${NC}"
    exit 1
else
    echo -e "\n===================================================="
    echo -e "${PURPLE}✅ CYBERANZEN NETWORK LAB IS LIVE!${NC}"
    echo -e "===================================================="
    echo -e "🔗 Access Link  : ${CYAN}$TUNNEL_URL${NC}"
    echo -e "👤 Username     : kasm_user"
    echo -e "🔑 Password     : Bootcamp2026!"
    echo -e "===================================================="
    echo -e "${YELLOW}>>> PRESS [CTRL+C] TO STOP THE LAB AND CLEAN UP RESOURCES <<<${NC}"
    
    monitor_idle &
    while true; do sleep 1; done
fi
