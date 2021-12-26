#!/bin/bash

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