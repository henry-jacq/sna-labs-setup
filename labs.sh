#!/bin/bash

SSH="/usr/bin/ssh"
WG="/usr/bin/wg"
NCAT="/usr/bin/nc"
NC="\e[0m"
RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
ORANGE="\e[33m"
ECHO="echo -e"
READ="read -p"
SLEEP="sleep 0.5"
PORT=22
TIMEOUT=3
OS_RELEASE="/etc/os-release"
WG_LOCATION="/etc/wireguard"
LABSCONNECT_LCT="/usr/bin/labconnect"
WG_CONF_LOCATION="/etc/wireguard/wg0.conf"
DEB_PMI="apt-get --yes -qq install"
INFO="(This setup is still in beta stage)"
DPDCIES_PKG="wireguard-tools"
LABS="https://labs.selfmade.ninja"
GIT_SERVER="https://git.selfmade.ninja"

################################################################################
dependencies_install () {

# while [[ $DEPENDENCIES_PKG ]]; do
#     if apt-get -qq install $DEPENDENCIES_PKG; then
#         $ECHO "${GREEN}[+] Dependencies are Installed${NC}"
#         break
#     else
#         $ECHO "${RED}[-] Dependencies are not Installed${NC}"
#     fi
# done

while [[ $DPDCIES_PKG ]]; do
    if command -v wg > /dev/null ; then
            $ECHO "${GREEN}[+] Dependencies are Installed${NC}"
            break
    else
        $ECHO "${RED}[-] Dependencies are not Installed${NC}"
        $ECHO "${GREEN}[*] Installing Dependencies${NC}"
        apt-get update
        $DEB_PMI $DPDCIES_PKG
        $ECHO "${GREEN}[+] Dependencies are Installed${NC}"
        break
    fi
done

# if command -v ${DEPENDENCIES} >/dev/null 2>&1 ; then
#     $ECHO "${GREEN}[+] All the Dependencies are Installed${NC}"
# #     $ECHO "[+] version: $(wg -v)"
# else
#     #$ECHO "${RED}[-] Installing all the Dependencies${NC}"
#     echo "Are not found ${DEPENDENCIES}"
#     #$DEB_PMI ${DEPENDENCIES} -y
# fi

# if command -v ${DEPENDENCIES[*]} >/dev/null 2>&1 ; then
#     $ECHO "${GREEN}[+] All the Dependencies are Installed${NC}"
# #     $ECHO "[+] version: $(wg -v)"
# else
#     $ECHO "${RED}[-] Installing all the Dependencies${NC}"
#     echo "Installing ${DEPENDENCIES[*]}"
#     $DEB_PMI ${DEPENDENCIES[*]} -y
# fi
# }
}

main_menu () {
$ECHO "${ORANGE}\n\tSelfmade Labs Setup for Linux v1.0${NC} 🐧\n"
$ECHO "${BLUE}\t   $LABS\n${NC}"
$ECHO "  Developed by ${BLUE}https://git.selfmade.ninja/Henry${NC}\n"
# $ECHO "\t$INFO\n"

source $OS_RELEASE

if [ -f "$OS_RELEASE" ]; then
    $ECHO "${BLUE}OS: ${NC}$PRETTY_NAME ${GREEN}[Detected]${NC}"
else
    $ECHO "${BLUE}OS: ${NC}Unknown OS ${RED}\t[Not-Detected]${NC}"
fi
$ECHO "${RED}Root Privileges ${NC} ${GREEN}[Detected]${NC}\n"

$ECHO "1) Install Dependencies\n"
$ECHO "2) Generate ssh-keys\n"
$ECHO "3) Generate Wireguard keys\n"
$ECHO "4) Edit Wireguard Configs\n"
$ECHO "5) Wireguard status\n"
$ECHO "6) Connect to Labs\n"
$ECHO "7) Install VSCode\n"
$ECHO "q) Quit\n"
}

wg_gen_key () {
    
    #if [ -d $(pwd) ]; then
        if [[ -f $(pwd)/privatekey && $(pwd)/pubkey ]]; then
            $ECHO "${BLUE}[*] Wg Keys already exist!${NC}"
            $READ "[?] Want to overwrite ? (y/n) " WG_GENKY
            while [ $WG_GENKY ]; do
                if [ $WG_GENKY == "y" ]; then
                    $WG genkey | tee privatekey | $WG pubkey > publickey
                    $ECHO "${GREEN}[+] Successfully overwrited${NC}"
                    break
                elif [ $WG_GENKY == "n" ]; then
                    break
                fi
            done
            $ECHO "${BLUE}[*] Your wg keys${NC}"
            $ECHO "${GREEN}[+] PublicKey: $(cat publickey)${NC}"
            $ECHO "${GREEN}[+] PrivateKey: ${RED}(hidden)${NC}${NC}"
            $ECHO "${GREEN}[*] Copy and paste the publickey to $LABS${NC}"
        else
            #$ECHO "${RED}[*] Keys does not exist!${NC}"
            $ECHO "${GREEN}[*] Generating public/private key pair${NC}"
            $SLEEP
            $ECHO "${GREEN}[*] wg keys saved at [$(pwd)]${NC}"
            $WG genkey | tee privatekey | $WG pubkey > publickey
            $ECHO "${BLUE}[*] Your WG keys${NC}"
            $ECHO "${GREEN}[+] PublicKey: $(cat publickey)${NC}"
            $ECHO "${GREEN}[+] PrivateKey: ${RED}(hidden)${NC}${NC}"
            $ECHO "${GREEN}[*] Copy and paste the publickey to $LABS${NC}"
        fi 
    #fi
}

sshkeys () {
$ECHO "${GREEN}[+] Generating SSH keys${NC}"
ssh-keygen -t rsa -b 2048
$ECHO "${GREEN}[+] Generated SSH public key${NC}"
$ECHO $(cat $HOME/.ssh/id_rsa.pub)
$ECHO "${GREEN}[+] Copy and Paste this publickey to ($GIT_SERVER) If you don't paste that key, you can't access the labs.${NC}"
}

wg_status () {
    if [[ $(ifconfig wg0) ]]; then
        $ECHO "${GREEN}[+] Wireguard running...${NC}"
        wg show
    #     $WG show
    #     $READ "[?] Want to deactivate the interface wg0 (y/n) " stat_in
    #     if [ "$stat_in" == "y" ]; then
    #         $ECHO "${RED}[-] Deactivating wireguard Interface...${NC}"
    #         wg-quick down wg0
    #         $ECHO "${RED}[-] The Interface wg0 is dead...${NC}"
            
    #     elif [ "$stat_in" == "n" ]; then
            # $ECHO "${RED}[*] Exiting !${NC}"
    #     else
    #         $ECHO "${RED}[-] Invalid Option${NC}"
    #     fi
    else
        $ECHO "${RED}[-] The Interface wg0 is Down${NC}"
        $ECHO "${BLUE}[*] Once you enable, wireguard will run automatically at startup from the next boot${NC}"
        $READ "[?] Want to active the Wireguard Interface (y/n) " stat_out
        if [ "$stat_out" == "y" ]; then
            $ECHO "${GREEN}[+] Activating wireguard Interface...${NC}"
            wg-quick up wg0 || $ECHO "[-] Connection Failed"
            $ECHO "${GREEN}[+] wireguard Interface running...${NC}"
            $WG show

        elif [ "$stat_out" == "n" ]; then
            $ECHO "${RED}[*] Exiting !${NC}"
        else
            $ECHO "${RED}[-] Invalid Option${NC}"
        fi
    fi
    
}

install_vscode () {
    $ECHO "${GREEN}[*] Downloading VS Code...${NC}"
    wget https://az764295.vo.msecnd.net/stable/3866c3553be8b268c8a7f8c0482c0c0177aa8bfa/code_1.59.1-1629375198_amd64.deb
    $ECHO "${GREEN}[*] Installing VS Code...${NC}"
    dpkg -i code_1.59.1-1629375198_amd64.deb 
    $ECHO "${GREEN}[+] VS Code Installed${NC}"
    rm code_1.59.1-1629375198_amd64.deb
}

# Not Included in Main Menu
configs () {
$ECHO "
[Interface]
PrivateKey = $(cat privatekey)
Address = $1

[Peer]
PublicKey = cm9KJKYKSfXynAgznrH8+8JzYwxdk1Sn62/YWV/amW4=
AllowedIPs = 172.20.0.0/16
Endpoint = vpn.selfmade.ninja:44556
PersistentKeepalive = 30
"
}

# Not Included in Main Menu
wg_conf_checking () {
    $READ "[?] Want to $1 to that file (y/n) " wgconfm
    while [ $wgconfm ]; do
                if [ $wgconfm == "y" ]; then
                    
                    if [[ -f privatekey && publickey ]]; then
                        $ECHO "${GREEN}[*] Using the existing Wireguard Keys${NC}"
                        $ECHO "${GREEN}[*] Generated Private/Public key echoed to $WG_LOCATION/wg0.conf${NC}"
                        $ECHO "${GREEN}[*] Copy and Paste the Address that given in ($LABS) under peer section with CIDR notation (/32). Example given below${NC}"
                    else
                        $ECHO "${RED}[-] Wireguard Keys does not exist! Generate New one${NC}"
                        break
                    fi
                    
                    # $ECHO "Address and AllowedIPs are echoed"
                    $READ "[?] Enter Address [Example: 172.20.0.70/32]: " WG_ADDR
                    # Checking for valid IPs using regex
                    while [ $WG_ADDR ]; do
                        if [[ "$WG_ADDR" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$ ]]; then
                            $ECHO "${GREEN}[*] Valid Address!${NC}"
                            break
                        else
                            $ECHO "${RED}[*] Invalid IP. Try again${NC}"
                            $READ "[?] Enter Address [168.26.0.30/32]: " WG_ADDR
                        fi
                    done
                    configs $WG_ADDR > $WG_CONF_LOCATION
                    $SLEEP
                    $ECHO "${BLUE}[*] Your Wireguard Configuration [$WG_CONF_LOCATION]${NC}"
                    WG_CAT=$(cat $WG_CONF_LOCATION)
                    $ECHO "${ORANGE}$WG_CAT${NC}\n"
                    break
                    
                elif [ $wgconfm == "n" ]; then
                    $SLEEP
                    $ECHO "${BLUE}[*] Your Wireguard Configuration [$WG_CONF_LOCATION]${NC}"
                    WG_CAT=$(cat $WG_CONF_LOCATION)
                    $ECHO "${ORANGE}$WG_CAT${NC}\n"
                    $ECHO "${RED}[*] Exiting !${NC}"
                    break
                else
                    $ECHO "${RED}[-] Invalid Option${NC}"
                fi
            done
}

wgconf () {

while [ $WG_LOCATION ]; do
    if [ -d /etc/wireguard/ ]; then
        if [ -f $WG_CONF_LOCATION ]; then
            $ECHO "${GREEN}[+] '$WG_CONF_LOCATION' file exists${NC}"
            wg_conf_checking "change configs"
            break
        else
            $ECHO "${RED}[-] '$WG_CONF_LOCATION' File does not Exist${NC}"
            $ECHO "${GREEN}[*] Creating one${NC}"
            touch $WG_CONF_LOCATION
            $SLEEP
            wg_conf_checking "add configs"
            break
        fi      
    else
        $ECHO "${RED}[-] '/etc/wireguard/' directory not found !${NC}"
        $ECHO "${GREEN}[*] Creating directory '/etc/wireguard/' ${NC}"
        $SLEEP
        mkdir $WG_LOCATION
        $SLEEP
    fi
done

}

################################################################################

connect_labs () {
    
    if [ -f /usr/bin/labconnect ]; then
        $READ "[?] Want to change the existing ssh configs (y/n) " lab_cmd
        while [[ $lab_cmd ]]; do
            if [ "$lab_cmd" == "y" ]; then
                $ECHO "${BLUE}[*] Carefully Enter the Username and Labs IP, because these are saved in configs\n    for Future use. If you entered a wrong info, try the process again !${NC}"
                while [ $lab_cmd ]; do
                    $READ "[*] Enter the Username: " USERNAME
                    if [[ $USERNAME ]]; then
                        break
                    else
                        $ECHO "${RED}[-] Username Invalid${NC}"
                    fi
                done
            
                while [ $lab_cmd ]; do
                    $READ "[*] Enter the Labs IP: " LABS_IP
                    if [[ "$LABS_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        break
                    else
                        $ECHO "${RED}[-] Invalid IP !${NC}"
                    fi
                done
                    $ECHO "-" | $NCAT -w $TIMEOUT $LABS_IP $PORT &> /dev/null
                
                    if [ $? -eq 0 ]; then
                        $ECHO "${GREEN}[+] Trying to ssh $USERNAME@$LABS_IP${NC}"
                        $SLEEP
                        $ECHO "${GREEN}[+] Connection Available${NC}"
                        $SLEEP
                        $ECHO "${GREEN}[+] Establishing the Connection${NC}"
                        $SSH $USERNAME@$LABS_IP || $ECHO "${RED}[-] Connection Failed"
                    else
                        $ECHO "${GREEN}[+] Trying to ssh $USERNAME@$LABS_IP${NC}"
                        $SLEEP
                        $ECHO "${RED}[-] Connection Not available ${NC}"
                        $ECHO "${BLUE}Note:${NC}"
                        $ECHO "${BLUE}[*] Try to ping 172.20.0.1${NC}"
                        $ECHO "${BLUE}[*] Try to redeploy the machine${NC}"
                        $ECHO "${BLUE}[*] Check your Internet Connectivity${NC}"
                        $ECHO "${BLUE}[*] Check That the Wireguard Interface Up or not${NC}"
                        $ECHO "${BLUE}[*] Check That the generated ssh-keys are uploaded to $GIT_SERVER ${NC}"
                    fi
                break

            elif [ "$lab_cmd" == "n" ]; then
                $ECHO "${GREEN}[*] Trying to ssh using existing configs...${NC}"
                $LABSCONNECT_LCT || $ECHO "${RED}[-] Connection Failed"
                break
            fi
        done
    ###############################################################################################################################
    else
            $ECHO "${BLUE}[*] Carefully Enter the Username and Labs IP, because these are saved in configs\n    for Future use. If you entered a wrong info, try the process again !${NC}"
                while [[ connect_labs ]]; do
                    $READ "[*] Enter the Username: " USERNAME
                    if [[ $USERNAME ]]; then
                        break
                    else
                        $ECHO "${RED}[-] Username Invalid${NC}"
                    fi
                done
                
                
                while [[ connect_labs ]]; do
                    $READ "[*] Enter the Labs IP: " LABS_IP
                    if [[ "$LABS_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        break
                    else
                        $ECHO "${RED}[-] Invalid IP !${NC}"
                    fi
                done

                $ECHO "-" | $NCAT -w $TIMEOUT $LABS_IP $PORT &> /dev/null
                
                if [ $? -eq 0 ]; then
                    $ECHO "${GREEN}[+] Trying to ssh $USERNAME@$LABS_IP${NC}"
                    $SLEEP
                    $ECHO "${GREEN}[+] Connection Available${NC}"
                    $SLEEP
                    $ECHO "${GREEN}[+] Establishing the Connection${NC}"
                    $SSH $USERNAME@$LABS_IP
                    touch $LABSCONNECT_LCT
                    chmod +x $LABSCONNECT_LCT
                    $ECHO "#!/bin/bash" > $LABSCONNECT_LCT
                    $ECHO "ssh $USERNAME@$LABS_IP" >> $LABSCONNECT_LCT
                    $ECHO "${GREEN}[+] Command Created [/usr/bin/labconnect] ${NC}"
                    $ECHO "${GREEN}[+] You can use this command 'sudo labconnect' to access labs directly without running this script${NC}"

                else
                    $ECHO "${GREEN}[+] Trying to ssh $USERNAME@$LABS_IP${NC}"
                    $SLEEP
                    $ECHO "${RED}[-] Connection Not available ${NC}"
                    $ECHO "${BLUE}Note:${NC}"
                    $ECHO "${BLUE}[*] Try to ping 172.20.0.1${NC}"
                    $ECHO "${BLUE}[*] Try to redeploy the machine${NC}"
                    $ECHO "${BLUE}[*] Check your Internet Connectivity${NC}"
                    $ECHO "${BLUE}[*] Check That the Wireguard Interface Up or not${NC}"
                    $ECHO "${BLUE}[*] Check That the generated ssh-keys are uploaded to $GIT_SERVER ${NC}"
                fi
    fi

}


################################################################################

# try to install nc in startup

if [ "$EUID" -ne 0 ]; then
    $ECHO "${RED}[-] Please run as root ${NC}"
    exit
else
    if [[ -f /usr/bin/nc ]]; then
        echo ""
        clear
    else
        echo "Wait a few seconds.."
        $DEB_PMI nc > /dev/null 2>&1
        clear
    fi
    main_menu
    while :
    do
        $READ ">> " INPUT_STRING
        case $INPUT_STRING in
            1)
                dependencies_install
                ;;
            2)
                sshkeys
                ;;
            3)
                wg_gen_key
                ;;
            4)
                wgconf
                ;;
            5)
                wg_status
                ;;
            6)
                connect_labs
                ;;
            7)
                install_vscode

                ;;
            q)
                $ECHO "See you again!"
                exit
                ;;
            *)
                $ECHO "${RED}[-] Enter the valid number${NC}"
                ;;
        esac
    done
fi
