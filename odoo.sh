#!/bin/bash
RED='\e[31m'
# GREEN='\e[32m'
RESET='\e[0m'
YELLOW='\e[33m'
BOLD='\e[1m'

if [ "${2^^}" != "UP" ] && [ "${2^^}" != "DOWN" ] && [ "${2^^}" != "LOG" ]; then
    echo -e "${RED}You have not put the type of operation: ${BOLD}[UP/DOWN/LOG]${RESET}"
    echo -e "${RED}Example: ${BOLD}./odoo.sh sample UP${RESET}"
    exit 1
fi


if [ -z "$1" ]; then
    echo -e "${RED}You have not set the odoo configuration argument${RESET}"
    echo -e "${RED}Example: ${BOLD}./odoo.sh sample UP${RESET}"
    echo -e "${YELLOW}You can see the available configurations in ${BOLD}config${RESET}${YELLOW} directory${BOLD}"
    ls config
    echo -e "${RESET}"
    exit 1
fi

if [ ! -d "config/$1" ]; then
    echo -e "${RED}Directory does not exist${RESET}"
    echo -e "${YELLOW}You can see the available configurations in ${BOLD}config${RESET}${YELLOW} directory${BOLD}"
    ls config
    echo -e "${RESET}"
    exit 1
fi


export WEB_HOSTNAME=$1

if [ "${2^^}" == "UP" ]; then
    docker compose --env-file config/$1/.env up -d
    exit 0
fi

if [ "${2^^}" == "DOWN" ]; then
    docker compose --env-file config/$1/.env down
    exit 0
fi

if [ "${2^^}" == "LOG" ]; then
    docker compose --env-file config/$1/.env logs -f
    exit 0
fi