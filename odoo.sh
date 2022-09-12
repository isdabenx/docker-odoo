#!/bin/bash
RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
YELLOW='\e[33m'
BOLD='\e[1m'

CONFIG_DIR=''
ACTION='STATUS'
MODULES=''
PGADMIN=false

show_help() {
    echo -e "${RESET}${BOLD}Usage: $0 -c DIRECTORY_NAME [OPTIONS]${RESET}"
    echo -e "${BOLD}Options:${RESET}"
    echo -e "${BOLD} -h${RESET} Show this help message and exit."
    echo -e "${BOLD} -c <DIRECTORY>${RESET} Name of the directory where there is the configuration of the instance and the Odoo modules."
    echo -e "${BOLD} -u${RESET} Start docker Odoo/Postgres containers."
    echo -e "${BOLD} -p${RESET} Start docker pgadmin container. Can be used with -u."
    echo -e "${BOLD} -d${RESET} Stop all docker containers."
    echo -e "${BOLD} -r${RESET} Restart docker Odoo container."
    echo -e "${BOLD} -l${RESET} Show Odoo logs."
    echo -e "${BOLD} -L${RESET} Show docker container logs."
    echo -e "${BOLD} -U <modules separated by , without space>${RESET} Update modules on Odoo."
    echo -e "${BOLD} -I <modules separated by , without space>${RESET} Install modules on Odoo."
    exit 0
}

syntax_error() {
    echo -e "${RED}Syntax error: $1${RESET}"
    echo -e "${YELLOW}Try '$0 -h' for more information.${RESET}"
    exit 1
}

set_action() {
    if [ "$ACTION" != "STATUS" ]; then
        syntax_error "Only one option is allowed."
    fi
    ACTION=$1
}

run_pgadmin() {
    if [ "$PGADMIN" = true ]; then
        docker compose --env-file config/$CONFIG_DIR/.env up -d pgadmin
    fi
}

run_docker() {
    docker compose --env-file config/$CONFIG_DIR/.env $*
}

while getopts ":hc:updrlLU:I:" option; do
    case $option in
    h) show_help ;;
    c) CONFIG_DIR=$OPTARG ;;
    u) set_action "UP" ;;
    p) PGADMIN=true ;;
    d) set_action "DOWN" ;;
    r) set_action "RESTART" ;;
    l) set_action "LOG" ;;
    L) set_action "LOGS" ;;
    U)
        set_action "UPDATE"
        MODULES=$OPTARG
        ;;
    I)
        set_action "INSTALL"
        MODULES=$OPTARG
        ;;
    :) syntax_error "Option -$OPTARG requires an argument." ;;
    \?) syntax_error "Invalid option: -${OPTARG}" ;;
    esac
done

if [ -z "$CONFIG_DIR" ]; then
    syntax_error "Option -c is required."
fi

if [ ! -d "config/$CONFIG_DIR" ]; then
    echo -e "${RED}Directory does not exist${RESET}"
    echo -e "${YELLOW}You can see the available configurations in ${BOLD}config${RESET}${YELLOW} directory${BOLD}"
    ls config
    echo -e "${RESET}"
    exit 1
fi

export WEB_HOSTNAME=$CONFIG_DIR

case $ACTION in
"STATUS")
    if [ "$PGADMIN" = true ]; then
        run_pgadmin
    else
        run_docker ps
    fi
    ;;
"UP")
    run_docker up -d odoo
    run_pgadmin
    ;;
"DOWN") run_docker down ;;
"RESTART") run_docker restart odoo ;;
"LOG") run_docker logs -f odoo ;;
"LOGS") run_docker logs -f ;;
"UPDATE") echo -e "${GREEN}Not implemented yet${RESET}" ;;
"INSTALL") echo -e "${GREEN}Not implemented yet${RESET}" ;;
esac

exit 0
