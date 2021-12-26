#!/bin/bash

# colours
NC="\e[0m"
RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
ORANGE="\e[33m"
SLEEP="sleep 0.5"
# commands
ECHO="echo -e"
GIT="https://git.selfmade.ninja"

function sshkeys () {
    $ECHO "\n\t[*] ${ORANGE}This is step is run through the user: ${NC}${GREEN}$USER${NC}" && $SLEEP
    $ECHO "\n\t[*] ${ORANGE}Generating SSH key pair${NC}" && $SLEEP
    ssh-keygen -t rsa -b 2048
    $ECHO "$\n\t[*] ${GREEN}Generated SSH public key${NC}"
    $ECHO $(cat $HOME/.ssh/id_rsa.pub)
    $ECHO "\n\t[*] ${GREEN}Copy and Paste this publickey to (${GIT}-/profile/keys) If you don't paste that key, you can't access the labs.${NC}"
}

sshkeys