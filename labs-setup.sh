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
# Version      : 1.21
# Usage        : sudo ./labs-setup.sh
# Bash Version : 4.2 or later
# Info         : This script is still in development. If you found any issues, please open a issue in the respective git repositories.

# colours
NC="\e[0m"
RED="\e[31m"
GREEN="\e[32m"
ORANGE="\e[33m"
BLUE="\e[34m"
VIOLET="\e[35m]"
LIGHTBLUE="\e[36m]"
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
WG_SERV_PUB_KEY="cm9KJKYKSfXynAgznrH8+8JzYwxdk1Sn62/YWV/amW4="
WG_ALLOWED_IPS="172.20.0.0/32"
WG_ENDPOINT="vpn.selfmade.ninja:44556"
WG_PERSISTENT_KEEPALIVE="30"
# new command
LABSCONNECT_LCT="/usr/bin/labconnect"
# links
LABS="https://labs.selfmade.ninja"
GIT_SERVER="https://git.selfmade.ninja"
# version
VER_INFO="v1.12"

$ECHO "${GREEN}${NC}"

# Called by other functions [common]

function help_box(){
    $ECHO "\t" && banner_common
    $ECHO "\n\tAvailable arguments: "
    $ECHO "\t--------------------------------------------------------------------------------\n"
    $ECHO "\t-h or --help:\t\t\tPrint this help text.\n"
    $ECHO "\t-i or --interactive:\t\tThis mode allows user to interact with a shell.\n "
    $ECHO "\t-f or --force:\t\t\tIt forces the process by the default values.\n"
    $ECHO "\t-v or --version:\t\tPrint the version information.\n"
    $ECHO "\t--------------------------------------------------------------------------------\n"
    
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

# For dependencies check
# This is not called by main_call
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

function root_perm_check() {
    if [ "$EUID" -ne 0 ]; then
        $ECHO "\n\t[-] ${RED}Please run as root.${NC}" && $SLEEP
        exit
    fi
}

function warning_force(){
    $ECHO "${RED}\t---------------------------------------------------------------------------------${NC}"
    $ECHO "${RED}\t| WARNING:\t\t\t\t\t\t\t\t\t|\n\t|\tFORCE MODE OVERWRITES ALL THE DATA RELATED TO 'WIREGUARD CONFIGS' AND \t| \n\t|\t'SSH-KEYS' IF IT EXISTS. THIS MODE IS RECOMMENDED FOR FIRST TIME SETTING|\n\t|\tUP, IF YOU NEED TO CHANGE CONFIGS AND OTHER THINGS USE INTERACTIVE MODE\t|${NC}"
    $ECHO "${RED}\t---------------------------------------------------------------------------------\n${NC}"
    # $ECHO "\e[41m\t---------------------------------------------------------------------------------${NC}"
    # $ECHO "\e[41m\t| WARNING:                                                                      |\n\t|       FORCE MODE OVERWRITES ALL THE DATA RELATED TO 'WIREGUARD CONFIGS' AND   |\n\t|       'SSH-KEYS' IF IT EXISTS. THIS MODE IS RECOMMENDED FOR FIRST TIME SETTING|\n\t|       UP, IF YOU NEED TO CHANGE CONFIGS AND OTHER THINGS USE INTERACTIVE MODE |${NC}"
    # $ECHO "\e[41m\t---------------------------------------------------------------------------------\n${NC}
    
    $READ "        [?] If you agree to this hit [Enter] to continue or hit ctrl+c to stop this." && $SLEEP
    $ECHO "\n\t${ORANGE}=================================================================================${NC}\n"
}

function intro_com(){
    $SLEEP
    source $OS_RELEASE
    
    if [ -f "$OS_RELEASE" ]; then
        $ECHO "\t[I] ${BLUE}$PRETTY_NAME $(uname -i)${NC}\t${GREEN}[Detected] [Supported]${NC}" && $SLEEP
    else
        $ECHO "\t[I] ${BLUE}Unknown OS${NC}${RED}\t[Detected] [Unsupported]${NC}"
    fi
    
    if [ $UID -eq 0 ]; then
        $ECHO "\n\t[I] ${RED}Root privileges ${NC}${GREEN}\t[Detected]${NC}"
    else
        $ECHO "\n\t[-] ${RED}Root privileges ${NC}${RED}\t[Not-Detected]${NC}"
    fi
    
    $ECHO "\n\t[I] ${ORANGE}Force mode\t\t${NC}:${GREEN} $1 ${NC}" && $SLEEP
    $ECHO "\n\t[I] ${ORANGE}Interactive mode\t${NC}:${GREEN} $2 ${NC}" && $SLEEP
    $ECHO "\n\t[I] ${BLUE}Entering into force mode${NC}"
    $ECHO "\n\t[+] ${ORANGE}User${NC}:${GREEN} $USER${NC}"
}

function force_start(){
    pm_checker
    $SLEEP
    $ECHO "\n\t[*] ${ORANGE}Initializing package manager verification${NC}" && sleep 1
    $ECHO "\n\t[*] ${ORANGE}Package Manager${NC}: ${GREEN}${PM}${NC}" && $SLEEP
    dependencies_install
}

function post_sshkeys(){
    $ECHO "\n\t================================================================================="
    runuser -l $(users | awk '{print $1}') -c "cd ~/sna-labs-setup/ && ./ssh-keygen.sh"
}

function wg_gen_key_force () {
    $ECHO "\n\t================================================================================="
    $ECHO "\n\t[*] ${ORANGE}Initializing wireguard key pair generation...${NC}" && $SLEEP
    cd ${WG_LOCATION}
    if [[ -f ${WG_LOCATION}/privatekey && ${WG_LOCATION}/publickey ]]; then
        $ECHO "\n\t[*] ${RED}Wireguard Keys already exist !${NC}" && $SLEEP
        $ECHO "\n\t[*] ${BLUE}Removing the existing keys and regenerating new one${NC}" && $SLEEP
        $WG genkey | tee privatekey | $WG pubkey > publickey
        $ECHO "\n\t[+] ${GREEN}Successfully regenerated !${NC}" && $SLEEP
        $ECHO "\n\t[!] ${GREEN}Regenerated Wireguard keys${NC}"
        $ECHO "\n\t[+] ${GREEN}PublicKey: ${NC}$(cat publickey)"
        $ECHO "\n\t[+] ${GREEN}PrivateKey: ${RED}(hidden)${NC}${NC}"
        $ECHO "\n\t[*] ${GREEN}Copy and paste the publickey to ${NC}(${LABS}/devices/add) ${GREEN}for\n\t    accessing labs through this VPN${NC}\n"
        $READ "        [*] If you done this press [Enter] to continue..."
    else
        $ECHO "\n\t================================================================================="
        $ECHO "\n\t[*] ${ORANGE}Initializing wireguard key pair generation...${NC}" && $SLEEP
        $SLEEP
        $ECHO "\n\t[*] ${GREEN}wg keys saved at [${WG_LOCATION})]${NC}"
        $WG genkey | tee privatekey | $WG pubkey > publickey
        $ECHO "\n\t[!] ${GREEN}Wireguard keys${NC}"
        $ECHO "\n\t[+] ${GREEN}PublicKey: ${NC}$(cat publickey)"
        $ECHO "\n\t[+] ${GREEN}PrivateKey: ${RED}(hidden)${NC}${NC}"
        $ECHO "\n\t[*] ${GREEN}Copy and paste the publickey to ${NC}(${LABS}/devices/add) ${GREEN}for\n\t    accessing labs through this VPN${NC}\n"
        $READ "        [*] If you done this press [Enter] to continue..."
    fi
}

# This is not called by main_call
function wg_conf_checking(){
    $ECHO "\n\t================================================================================="
    $ECHO "\n\t${ORANGE}Analyzing wireguard configuration...${NC}" && $SLEEP
    cd ${WG_LOCATION}
    if [[ -f ${WG_LOCATION}/wg0.conf ]]; then
        $ECHO "\n\t[*] ${RED}Wireguard configuration already exists !${NC}" && $SLEEP
        $ECHO "\n\t[*] ${BLUE}Overwriting the existing configuration${NC}" && $SLEEP
        $ECHO "" > $WG_CONF_LOCATION && $SLEEP
        $ECHO "[Interface]" > $WG_CONF_LOCATION
        $ECHO "PrivateKey = $(cat privatekey)" >> $WG_CONF_LOCATION
        $ECHO "Address = ${1}/32" >> $WG_CONF_LOCATION
        $ECHO "" >> $WG_CONF_LOCATION
        $ECHO "[Peer]" >> $WG_CONF_LOCATION
        $ECHO "PublicKey = $WG_SERV_PUB_KEY)" >> $WG_CONF_LOCATION
        $ECHO "AllowedIPs = $WG_ALLOWED_IPS" >> $WG_CONF_LOCATION
        $ECHO "Endpoint = $WG_ENDPOINT" >> $WG_CONF_LOCATION
        $ECHO "PersistentKeepalive = $WG_PERSISTENT_KEEPALIVE" >> $WG_CONF_LOCATION
        
        $ECHO "\n\t[*] ${GREEN}Config modified !${NC}" && $SLEEP
        $ECHO "\n\t[*] ${GREEN}wg0 conf saved at [$WG_CONF_LOCATION]${NC}"
    else
        $ECHO "\n\t================================================================================="
        $ECHO "\n\t[+] ${GREEN}Wireguard configuration doesn't exist !${NC}" && $SLEEP
        $ECHO "\n\t[*] ${ORANGE}Creating a new wireguard configuration...${NC}" && $SLEEP
        $ECHO "\n\t[!] ${GREEN}Generating new one...${NC}" && $SLEEP
        touch $WG_CONF_LOCATION && $SLEEP
        
        $ECHO "[Interface]" > $WG_CONF_LOCATION
        $ECHO "PrivateKey = $(cat privatekey)" >> $WG_CONF_LOCATION
        $ECHO "Address = ${1}/32" >> $WG_CONF_LOCATION
        $ECHO "" >> $WG_CONF_LOCATION
        $ECHO "[Peer]" >> $WG_CONF_LOCATION
        $ECHO "PublicKey = $WG_SERV_PUB_KEY)" >> $WG_CONF_LOCATION
        $ECHO "AllowedIPs = $WG_ALLOWED_IPS" >> $WG_CONF_LOCATION
        $ECHO "Endpoint = $WG_ENDPOINT" >> $WG_CONF_LOCATION
        $ECHO "PersistentKeepalive = $WG_PERSISTENT_KEEPALIVE" >> $WG_CONF_LOCATION
        
        $ECHO "\n\t[*] ${GREEN}Config generated !${NC}" && $SLEEP
        $ECHO "\n\t[*] ${GREEN}wg0 conf saved at [$WG_CONF_LOCATION]${NC}"
    fi 
}

function wg_gen_conf () {
    $ECHO "\n\t================================================================================="
    $ECHO "\n\t[*] ${ORANGE}Initializing wireguard config generation... ${NC}" && $SLEEP
    $ECHO "\n\t[*] ${BLUE} Copy the VPN IP of your device shown in labs!${NC}"
    $ECHO "\n\t[*] ${BLUE} Carefully enter the IP. It can't be changed because this is force mode\n${NC}"
    $READ "        [?] Enter the address [Example: 172.20.0.60]: " iprange
    
    while [ $WG_LOCATION ]; do
        if [ -d /etc/wireguard/ ]; then
            if [ -f $WG_CONF_LOCATION ]; then
                wg_conf_checking $iprange
                break
            else
                $ECHO "${RED}[-] '$WG_CONF_LOCATION' File does not Exist${NC}"
                $ECHO "${GREEN}[*] Creating one${NC}"
                touch $WG_CONF_LOCATION && $SLEEP
                wg_conf_checking $iprange
                break
            fi
        else
            $ECHO "${RED}[-] '/etc/wireguard/' directory not found !${NC}"
            $ECHO "${GREEN}[*] Creating directory '/etc/wireguard/' ${NC}" && $SLEEP
            mkdir $WG_LOCATION
        fi
    done
}

function check_wg_up_or_not(){
    $ECHO "\n\t================================================================================="
    $ECHO "\n\t${ORANGE}Checking if wireguard Interface is up or not...${NC}"
    $ECHO "\n\t================================================================================="
    
    pm_checker
    $PM_INSTALL net-tools > /dev/null 2>&1
    ifconfig wg0 > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        $ECHO "${GREEN}\n\t[+] Wireguard interface is running${NC}"
    else
        $ECHO "${RED}\n\t{RED}[-] The Interface wg0 is Down${NC}"
        $ECHO "${GREEN}\n\t[+] Activating wireguard Interface (wg0)${NC}"
        $(wg-quick up wg0) || $ECHO "[-] Connection Failed"
        $WG show
    fi
}

###############################################################################################

function connect_labs () {
    
    #### If labConnect exists #################################################################
    if [[ -f /usr/bin/labconnect ]]; then
        $ECHO "\n\t[*] ${GREEN}LabConnect is already installed !${NC}" && $SLEEP
        $ECHO "\n\t[*] ${BLUE}Started overwriting the labconnect...${NC}" && $SLEEP
        $ECHO "\n\t[*] ${BLUE}Carefully Enter the Username and Labs IP, because these are saved in config\n\t    for Future use.\n${NC}"
        # Getting the username
        while true; do
            $READ "        [*] Enter the Username: " USERNAME
            if [ $USERNAME ]; then
                break
            else
                $ECHO "\n\t[-] ${RED}Username Invalid\n${NC}"
            fi
        done
        $ECHO "\n"

        # Getting the labs IP
        while true; do
            $READ "        [*] Enter the Labs IP: " LABS_IP
            if [[ "$LABS_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            else
                $ECHO "\n\t[-] ${RED}Invalid IP! Try again${NC}\n"
            fi
        done
        
        # Testing if the connection to labs is available or not
        $ECHO "-" | $NCAT -w $TIMEOUT $LABS_IP $PORT &> /dev/null
        $ECHO "\n\t${GREEN}[+] Checking if the ssh connection ($USERNAME@$LABS_IP) possible or not${NC}"
        
        if [ $? -eq 0 ]; then
            $ECHO "\n\t${GREEN}[+] Connection available${NC}" && $SLEEP
            $ECHO "\n\t${GREEN}[+] Establishing the Connection${NC}"
            $SSH $USERNAME@$LABS_IP || $ECHO "\n\t${RED}[-] Connection Failed"
            $ECHO "#!/bin/bash" > $LABSCONNECT_LCT
            $ECHO "" >> $LABSCONNECT_LCT
            $ECHO "ssh $USERNAME@$LABS_IP" >> $LABSCONNECT_LCT
            $ECHO "\n\t${GREEN}[+] Command Recreated [/usr/bin/labconnect] ${NC}"
            $ECHO "\n\t${GREEN}[+] You can use this command 'sudo labconnect' to access labs directly without running this script${NC}"
        else
            $ECHO "\n\t${RED}[-] Connection not available ${NC}"
            $ECHO "${BLUE}Note:${NC}"
            $ECHO "${BLUE}[*] Try to ping 172.20.0.1 or 172.20.0.0${NC}"
            $ECHO "${BLUE}[*] Try to redeploy the labs${NC}"
            $ECHO "${BLUE}[*] Check your Internet Connectivity${NC}"
            $ECHO "${BLUE}[*] Check That the Wireguard Interface Up or not${NC}"
            $ECHO "${BLUE}[*] Check That the generated ssh-keys are uploaded to $GIT_SERVER ${NC}"
        fi
    
    #### If labConnect not exists #####################################################################
    else
        $ECHO "\n\t[*] ${BLUE}Carefully Enter the Username and Labs IP, because these are saved in config\n\t    for Future use.\n${NC}"
        
        # Getting the username
        while true; do
            $READ "        [*] Enter the Username: " USERNAME
            if [[ $USERNAME ]]; then
                break
            else
                $ECHO "\n\t[-] ${RED}Username Invalid${NC}\n"
            fi
        done
        
        $ECHO "\n"
        # Getting the labs IP
        while [[ connect_labs ]]; do
            $READ "        [*] Enter the Labs IP: " LABS_IP
            if [[ "$LABS_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            else
                $ECHO "\n\t[-] ${RED}Invalid IP !${NC}\n"
            fi
        done
        
        # Testing if the connection to labs is available or not
        $ECHO "-" | $NCAT -w $TIMEOUT $LABS_IP $PORT &> /dev/null
        $ECHO "\n\t${GREEN}[+] Checking if the ssh connection ($USERNAME@$LABS_IP) possible or not${NC}"
        
        if [ $? -eq 0 ]; then
            $ECHO "\n\t${GREEN}[+] Connection available${NC}" && $SLEEP
            $ECHO "\n\t${GREEN}[+] Establishing the Connection${NC}"
            $SSH $USERNAME@$LABS_IP || $ECHO "\n\t${RED}[-] Connection Failed"
            touch $LABSCONNECT_LCT
            chmod +x $LABSCONNECT_LCT
            $ECHO "#!/bin/bash" > $LABSCONNECT_LCT
            $ECHO "" >> $LABSCONNECT_LCT
            $ECHO "ssh $USERNAME@$LABS_IP" >> $LABSCONNECT_LCT
            $ECHO "\n\t${GREEN}[+] Command Created [/usr/bin/labconnect] ${NC}"
            $ECHO "\n\t${GREEN}[+] You can use this command 'sudo labconnect' to access labs directly without running this script${NC}"
        else
            $ECHO "\n\t[-] ${RED}Connection not available ${NC}"
            $ECHO "\n\t${BLUE}Note:${NC}"
            $ECHO "\n\t[*] ${BLUE}Try to ping 172.20.0.1${NC}"
            $ECHO "\n\t[*] ${BLUE}Try to redeploy the machine${NC}"
            $ECHO "\n\t[*] ${BLUE}Check your Internet Connectivity${NC}"
            $ECHO "\n\t[*] ${BLUE}Check That the Wireguard Interface Up or not${NC}"
            $ECHO "\n\t[*] ${BLUE}Check That the generated ssh-keys are uploaded to $GIT_SERVER ${NC}"
        fi
    fi
}

# banner_common
# root_perm_check
# warning_force
# intro_com
# force_start
# post_sshkeys
# wg_gen_key_force
# wg_gen_conf
# check_wg_up_or_not

function main_call(){
    
    if [[ $@ == "-h" ]]; then # help -h #############
        help_box
        $ECHO "\t${GREEN}[+] argument $@ is passed${NC}"
    elif [[ $@ == "--help" ]] # help #############
    then
        help_box
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
        root_perm_check
        warning_force
        intro_com "${GREEN}Enabled${NC}" "${RED}Disabled${NC}"
        force_start
        # post_sshkeys
        # wg_gen_key_force
        # wg_gen_conf
        # check_wg_up_or_not
        connect_labs
        
    elif [[ $@ == "--force" ]] # Force mode -f #############
    then
        banner_common
        root_perm_check
        warning_force
        intro_com "${GREEN}Enabled${NC}" "${RED}Disabled${NC}"
        force_start
        # post_sshkeys
        # wg_gen_key_force
        # wg_gen_conf
        # check_wg_up_or_not
        connect_labs
    else
        help_box
        $ECHO "\t${RED}Usage: $0 --help [USE ONE OPTION] \n${NC}"
        $ECHO "\t${RED}[-] No arguments is passed${NC}"
    fi
}

main_call "$@"