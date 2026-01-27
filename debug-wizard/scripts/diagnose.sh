#!/bin/bash

# diagnose.sh - Project Stack Diagnostic Tool (macOS / Linux)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}🔍 Starting Debug Wizard Diagnostic...${NC}"

# 1. Check Docker Service
echo -e "\n${YELLOW}[1/3] Checking Docker Service Status...${NC}"
if docker info > /dev/null 2>&1; then
    echo -e "${GREEN}Docker is running.${NC}"
else
    echo -e "${RED}Warning: Docker is not running or not accessible. Is Docker Desktop running?${NC}"
fi

# 2. Check Critical Ports
echo -e "\n${YELLOW}[2/3] Checking Critical Ports...${NC}"
declare -a ports=(
    "80|App Server"
    "3000|Grafana"
    "3100|Loki"
    "9090|Prometheus"
    "9100|Node Exporter"
    "8080|cAdvisor"
)

for entry in "${ports[@]}"; do
    IFS="|" read -r port service <<< "$entry"
    
    # Use nc (netcat) to check if port is listening on localhost
    if nc -z 127.0.0.1 "$port" > /dev/null 2>&1; then
         echo -e "${GREEN}[OK] Port $port ($service) is LISTENING.${NC}"
    else
         echo -e "${RED}[FAIL] Port $port ($service) is NOT listening.${NC}"
    fi
done

# 3. Check Container Status
echo -e "\n${YELLOW}[3/3] Checking Docker Containers...${NC}"
if command -v docker &> /dev/null; then
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo -e "${RED}Error: docker command not found.${NC}"
fi

echo -e "\n${CYAN}✅ Diagnostic Complete.${NC}"
