#!/bin/bash

BOLD="\033[1m"
UNDERLINE="\033[4m"
DARK_YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RESET="\033[0;32m"

execute_with_prompt() {
    echo -e "${BOLD}Executing: $1${RESET}"
    if eval "$1"; then
        echo "Command executed successfully."
    else
        echo -e "${BOLD}${DARK_YELLOW}Error executing command: $1${RESET}"
        exit 1
    fi
}

echo -e "${BOLD}${UNDERLINE}${DARK_YELLOW}Welcome to 0xTNPxSGT Allora Worker Node Installer${RESET}"
echo -e "${CYAN}Are you ready? (Y/N):${RESET}"
read -p "" response
echo

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${BOLD}${DARK_YELLOW}Error: You do not meet the required specifications. Exiting...${RESET}"
    echo
    exit 1
fi

echo -e "${BOLD}${DARK_YELLOW}Removing Old Folders Allora...${RESET}"
execute_with_prompt 'rm -rf allora.sh allora-chain/ basic-coin-prediction-node/'
echo

echo -e "${BOLD}${DARK_YELLOW}Installing Allora...${RESET}"
execute_with_prompt 'wget https://raw.githubusercontent.com/0xtnpxsgt/Allora3Wrkrs/main/alloraworker.sh && chmod +x alloraworker.sh && ./alloraworker.sh'
echo

echo -e "${BOLD}${DARK_YELLOW}Merging Process...${RESET}"
execute_with_prompt 'cd allora-chain/basic-coin-prediction-node/'
echo
execute_with_prompt 'docker compose down'
echo

echo -e "${BOLD}${DARK_YELLOW}Creating Worker.${RESET}"
execute_with_prompt 'mkdir workers'
echo
execute_with_prompt 'mkdir workers/worker-1 workers/worker-2'
echo
execute_with_prompt 'sudo chmod -R 777 workers/worker-1'
echo
execute_with_prompt 'sudo chmod -R 777 workers/worker-2'
echo
execute_with_prompt 'sudo docker run -it --entrypoint=bash -v ./workers/worker-1:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"'
echo
execute_with_prompt 'sudo docker run -it --entrypoint=bash -v ./workers/worker-2:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"'
echo

echo -e "${BOLD}${DARK_YELLOW}Replacing Compose YML...${RESET}"
execute_with_prompt 'rm -rf docker-compose.yml && nano docker-compose.yml'
echo

echo "${BOLD}${DARK_YELLOW}Preparing Complete${RESET}"
echo
