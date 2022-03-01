#!/bin/bash

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="SNA Lab setup tool"
TITLE="SNA Lab setup tool"
MENU="Main menu"

OPTIONS=(1 "Install Dependencies"
         2 "Generate ssh-keys"
         3 "Generate Wireguard keys"
         4 "Edit Wireguard Configs"
         5 "Wireguard status"
         6 "Connect to labs"
         7 "Install VScode")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo "You chose Option 1"
            ;;
        2)
            echo "You chose Option 2"
            ;;
        3)
            echo "You chose Option 3"
            ;;
        4)
			echo "You chose Option 4"
			;;
		5)
			echo "You chose Option 5"
			;;
		6)
			echo "You chose Option 6"
			;;
		7)
			echo "You chose Option 7"
			;;
esac
