#!/usr/bin/env bash

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m";
}

[[ $EUID -ne 0 ]] && yellow "请以root模式运行脚本" && exit 1

function install(){
    bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
}

function makeConfig(){
    
}