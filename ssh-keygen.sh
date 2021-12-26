#!/bin/bash

# colours
NC="\e[0m"
RED="\e[31m"
GREEN="\e[32m"
ORANGE="\e[33m"
BLUE="\e[34m"
VIOLET="\e[35m]"
LIGHTBLUE="\e[36m]"
SLEEP="sleep 0.5"
# commands
ECHO="echo -e"
READ="read -p"
GIT="https://git.selfmade.ninja"

function sshkeys () {
    $ECHO "\n\t[*] ${ORANGE}Initializing SSH key pair generation...${NC}" && $SLEEP
    $ECHO "\n\t[*] ${BLUE}This is step is run through the user: ${NC}${GREEN}$USER${NC}" && $SLEEP
    $ECHO "\n\t[*] ${ORANGE}Generating SSH key pair\n${NC}" && $SLEEP
    ssh-keygen -t rsa -b 2048
    $ECHO "$\n\t[*] ${GREEN}Generated SSH public keys${NC}"
    $ECHO "${BLUE}\n\t$(batcat $HOME/.ssh/*.pub)${NC}"
    $ECHO "\n\t[*] ${GREEN}Copy and Paste this publickey to ${NC}(${GIT}/-/profile/keys)${GREEN}\n\t    otherwise you can't access the labs.\n${NC}"
    $READ "        [*] If you done this press [Enter] to continue..."
}

sshkeys


# $ECHO "\n\t================================================================================="
# $ECHO "\n\t[*] ${ORANGE}Checking if wireguard is up or not...${NC}"
# if [[ $(systemctl is-active wg-quick@wg0) == "active" ]]; then
#     $ECHO "\n\t[+] ${GREEN}Wireguard is up !${NC}"
# else
#     $ECHO "\n\t[-] ${RED}Wireguard is down !${NC}" && $SLEEP
#     $ECHO "\n\t[*] ${ORANGE}Starting wireguard...${NC}"
#     $SLEEP
#     $WG-quick up wg0
#     if [ $? -eq 0 ]; then
#         $ECHO "\n\t[+] ${GREEN}Wireguard is up !${NC}"
#     else
#         $ECHO "\n\t[-] ${RED}Something went wrong while starting wireguard !${NC}" && $SLEEP
#         $ECHO "\n\t[*] ${ORANGE}Trying to start wireguard again...${NC}"
#         $SLEEP
#         $WG-quick up wg0
#         if [ $? -eq 0 ]; then
#             $ECHO "\n\t[+] ${GREEN}Wireguard is up !${NC}"
#         else
#             $ECHO "\n\t[-] ${RED}Something went wrong while starting wireguard again !${NC}" && $SLEEP
#             $ECHO "\n\t[*] ${ORANGE}Trying to start wireguard again...${NC}"
#             $SLEEP
#             $WG-quick up wg0
#             if [ $? -eq 0 ]; then
#                 $ECHO "\n\t[+] ${GREEN}Wireguard is up !${NC}"
#             else
#                 $ECHO "\n\t[-] ${RED}Something went wrong while starting wireguard again !${NC}" && $SLEEP
#                 $ECHO "\n\t[*] ${ORANGE}Trying to start wireguard again...${NC}"
#                 $SLEEP
#                 $WG-quick up wg0
#             fi
#         fi
#     fi
# fi