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

function uninstall(){
    xrayr uninstall
    rm /usr/bin/XrayR -f
}

function main(){
        clear
    red "=================================="
    echo "                           "
    red "    Acme.sh 域名证书一键申请脚本     "
    red "          by 小御坂的破站           "
    echo "                           "
    red "  Site: https://blog.misaka.rest  "
    red " 本脚本在kkkyg的原作上进行二次修改 "
    echo "                           "
    red "=================================="
    echo "                           "
    green "1. 安装XrayR"
    green "2. 配置XrayR"
    green "3. 卸载XrayR"
    green "0. 退出"
    echo "         "
    read -p "请输入数字:" NumberInput
    case "$NumberInput" in     
        1 ) install;;
        2 ) makeConfig;;
        3 ) uninstall;;
        0 ) exit 1      
    esac
}