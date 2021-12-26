#!/bin/bash

#  ██████╗███╗  ██╗ █████╗   ██╗      █████╗ ██████╗  ██████╗
# ██╔════╝████╗ ██║██╔══██╗  ██║     ██╔══██╗██╔══██╗██╔════╝
#  █████╗ ██╔██╗██║███████║  ██║     ███████║██████╦╝╚█████╗    SETUP
#  ╚═══██╗██║╚████║██╔══██║  ██║     ██╔══██║██╔══██╗ ╚═══██╗   SCRIPT
# ██████╔╝██║ ╚███║██║  ██║  ███████╗██║  ██║██████╦╝██████╔╝   FOR
# ╚═════╝ ╚═╝  ╚══╝╚═╝  ╚═╝  ╚══════╝╚═╝  ╚═╝╚═════╝ ╚═════╝    LINUX

# Title        : labs-setup.sh
# Description  : This is a multi-use bash script for Linux machines to connect to selfmade ninja labs.
# Author       : Henry
# Date         : 2021-12-25
# GitHub       : https://github.com/henry-jacq/
# Gitlab       : https://git.selfmade.ninja/Henry/
# Version      : 1.12
# Usage        : sudo ./labs-setup.sh
# Bash Version : 4.2 or later
# Info         : This script is still in development. If you found any issues, please open a issue in the respective git repositories.

# colours
NC="\e[0m"
RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
ORANGE="\e[33m"
# ssh connection test
PORT=22
TIMEOUT=3
SLEEP="sleep 0.5"
# commands
ECHO="echo -e"
READ="read -p"
SSH="/usr/bin/ssh"
WG="/usr/bin/wg"
NCAT="/usr/bin/nc"
# files
OS_RELEASE="/etc/os-release"
WG_LOCATION="/etc/wireguard"
WG_CONF_LOCATION="/etc/wireguard/wg0.conf"
# new command
LABSCONNECT_LCT="/usr/bin/labconnect"
# links
LABS="https://labs.selfmade.ninja"
GIT_SERVER="https://git.selfmade.ninja"
# version
VER_INFO="v1.12"

$ECHO "${GREEN}${NC}"


function banner_common(){
    
    $ECHO """${ORANGE}
	 ██████╗███╗  ██╗ █████╗   ██╗      █████╗ ██████╗  ██████╗
	██╔════╝████╗ ██║██╔══██╗  ██║     ██╔══██╗██╔══██╗██╔════╝
	 █████╗ ██╔██╗██║███████║  ██║     ███████║██████╦╝╚█████╗  SETUP
	 ╚═══██╗██║╚████║██╔══██║  ██║     ██╔══██║██╔══██╗ ╚═══██╗ SCRIPT
	██████╔╝██║ ╚███║██║  ██║  ███████╗██║  ██║██████╦╝██████╔╝ FOR
	╚═════╝ ╚═╝  ╚══╝╚═╝  ╚═╝  ╚══════╝╚═╝  ╚═╝╚═════╝ ╚═════╝  LINUX
    ${NC}"""
}

function help(){
    $ECHO "\t" && banner_common
    $ECHO "\n\tAvailable arguments: "
    $ECHO "\t--------------------------------------------------------------------------------\n"
    $ECHO "\t-h or --help:\t\t\tPrint this help text.\n"
    $ECHO "\t-i or --interactive:\t\tThis mode allows user to interact with a shell.\n "
    $ECHO "\t-f or --force:\t\t\tIt forces the process by the default values.\n"
    $ECHO "\t-v or --version:\t\tPrint the version information.\n"
    $ECHO "\t--------------------------------------------------------------------------------\n"
    
}

function warning_force(){
    $ECHO "${RED}\t---------------------------------------------------------------------------------${NC}"
    $ECHO "${RED}\t| WARNING:\t\t\t\t\t\t\t\t\t|\n\t|\tFORCE MODE OVERWRITES ALL THE DATA RELATED TO 'WIREGUARD AND SSH-KEYS'\t| \n\t|\tIF IT EXISTS\t\t\t\t\t\t\t\t|${NC}"
    $ECHO "${RED}\t---------------------------------------------------------------------------------\n${NC}"
    # $ECHO "\n\tIf you agree to this hit [Enter] to continue or hit ctrl+c to stop this."
    $READ "        [?] If you agree to this hit [Enter] to continue or hit ctrl+c to stop this." && $SLEEP
    $ECHO "\n\t${ORANGE}=================================================================================${NC}\n"
}

function pm_checker(){
    declare -A osInfo;
    osInfo[/etc/redhat-release]=yum
    osInfo[/etc/fedora-release]=dnf
    osInfo[/etc/arch-release]=pacman
    osInfo[/etc/SuSE-release]=zypp
    osInfo[/etc/debian_version]=apt-get
    
    for f in ${!osInfo[@]}
    do
        if [[ -f $f ]];then
            export PM=${osInfo[$f]}
        fi
    done
    
    if [[ $PM == "apt-get" ]];then
        export PM_INSTALL="$PM install"
        export PM_UPDATE="$PM update"
    elif [[ $PM == "dnf" ]]
    then
        export PM_INSTALL="$PM install"
        export PM_UPDATE="$PM update"
    elif [[ $PM == "yum" ]]
    then
        export PM_INSTALL="$PM install"
        export PM_UPDATE="$PM update"
    elif [[ $PM == "pacman" ]]
    then
        export PM_INSTALL="$PM -Syy"
        export PM_UPDATE="$PM -Syyu"
    elif [[ $PM == "zypp" ]]
    then
        export PM_INSTALL="$PM install"
        export PM_UPDATE="$PM update"
    else
        echo "Package manager not found"
    fi
    
}

function dependencies_install(){
    pm_checker
    packages=(
        "wireguard-tools"
    )
    if [[ $PM == "apt-get" ]]; then
        $PM_INSTALL wireguard > /dev/null 2>&1
    fi
    $ECHO "\n\t[*] ${ORANGE}Checking for dependencies...${NC}"
    
    if command -v wg-quick > /dev/null; then
        $ECHO "\n\t[+] ${GREEN}Dependencies are installed... ✅${NC}"
    else
        $ECHO "\n\t[-] ${RED}Dependencies are not installed... ⛔${NC}" && $SLEEP
        $ECHO "\n\t[*] ${ORANGE}Updating the Package Manager ($PM)${NC}"
        $PM_UPDATE > /dev/null 2>&1 && $SLEEP
        if [ $? -eq 0 ]; then
            $ECHO "\n\t[+] ${GREEN}Package Manager Got Updated !${NC}" && $SLEEP
        else
            $ECHO "\n\t[-] ${RED}Something wrong with your Package Manager, Kindly check it manually.${NC}" && $SLEEP
        fi
        $ECHO "\n\t[*] ${ORANGE}Trying to install dependencies...${NC}"
        $PM_INSTALL $packages > /dev/null 2>&1 && $SLEEP
        if [ $? -eq 0 ]; then
            $ECHO "\n\t[+] ${GREEN}Dependencies got installed !${NC}" && $SLEEP
        else
            $ECHO "\n\t[-] ${RED}Something wrong with your Package Manager, Kindly check it manually.${NC}" && $SLEEP
        fi
    fi
}

function post_sshkeys(){
    runuser -l $(users | awk '{print $1}') -c "cd ~/sna-labs-setup/ && ./ssh-keygen.sh"
}

function intro_com(){
    $SLEEP
    source $OS_RELEASE
    
    if [ -f "$OS_RELEASE" ]; then
        $ECHO "\t[I] ${BLUE}$PRETTY_NAME $(uname -i)${NC}\t${GREEN}[Detected] [Supported]${NC}" && $SLEEP
    else
        $ECHO "\t[I] ${BLUE}Unknown OS${NC}${RED}\t[Detected] [Unsupported]${NC}" && $SLEEP
    fi
    
    if [ $UID -eq 0 ]; then
        $ECHO "\n\t[I] ${RED}Root privileges ${NC}${GREEN}\t[Detected]${NC}" && $SLEEP
    else
        $ECHO "\n\t[I] ${RED}Root privileges ${NC}${RED}\t[Not-Detected]${NC}" && $SLEEP
    fi
    
    $ECHO "\n\t[I] ${ORANGE}Force mode\t\t${NC}:${GREEN} $1 ${NC}" && $SLEEP
    $ECHO "\n\t[I] ${ORANGE}Interactive mode\t${NC}:${GREEN} $2 ${NC}" && $SLEEP
    $ECHO "\n\t[I] ${BLUE}Entering into force mode${NC}" && $SLEEP
    $ECHO "\n\t[+] ${ORANGE}User${NC}:${GREEN} $USER${NC}" && $SLEEP
}

function force_start(){
    pm_checker
    $SLEEP
    $ECHO "\n\t[*] ${ORANGE}Initializing package manager verification${NC}" && sleep 1
    $ECHO "\n\t[*] ${ORANGE}Package Manager${NC}: ${GREEN}${PM}${NC}" && $SLEEP
    dependencies_install
}


function main_call(){
    
    if [[ $@ == "-h" ]]; then # help -h #############
        help
        $ECHO "\t${GREEN}[+] argument $@ is passed${NC}"
    elif [[ $@ == "--help" ]] # help #############
    then
        help
        $ECHO "\t${GREEN}[+] argument $@ is passed${NC}"
        
    elif [[ $@ == "-v" ]] # version -v #############
    then
        $ECHO "${GREEN}[+] argument $@ is passed${NC}"
        echo "Version: $VER_INFO"
    elif [[ $@ == "--version" ]] # version #############
    then
        $ECHO "${GREEN}[+] argument $@ is passed${NC}"
        echo "Version: $VER_INFO"
        
    elif [[ $@ == "-i" ]] # Interactive mode #############
    then
        banner_common
        $ECHO "\t${GREEN}[+] argument $@ is passed${NC}"
    elif [[ $@ == "--interactive" ]] # Interactive mode -i #############
    then
        banner_common
        $ECHO "\t${GREEN}[+] argument $@ is passed${NC}"
        
    elif [[ $@ == "-f" ]] # Force mode #############
    then
        banner_common
        warning_force
        intro_com "${GREEN}Enabled${NC}" "${RED}Disabled${NC}"
        force_start
        post_sshkeys
        
    elif [[ $@ == "--force" ]] # Force mode -f #############
    then
        banner_common
        warning_force
        intro_com "${GREEN}Enabled${NC}" "${RED}Disabled${NC}"
        force_start
        post_sshkeys
    else
        help
        $ECHO "\t${RED}Usage: $0 --help [USE ONE OPTION] \n${NC}"
        $ECHO "\t${RED}[-] No arguments is passed${NC}"
    fi
}

main_call "$@"
# $ECHO "${BLUE}\n\t[!] All arguments passed to this script:${NC} $@\n"
