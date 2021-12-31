#!/usr/bin/env bash

localIP = `curl ipget.net`
localIP4 = `curl -4 ipget.net`
localIP6 = `curl -6 ipget.net`

green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}

red(){
    echo -e "\033[31m$1\033[0m";
}

if [[ $(id -u) != 0 ]]; then
yellow " 请以root模式运行脚本"
exit 0
fi

[[ $(type -P yum) ]] && osapt='yum -y' || osapt='apt -y'
[[ $(type -P curl) ]] || (yellow "curl未安装，正在安装中" && $osapt install curl)
[[ $(type -P socat) ]] || (yellow "socat未安装，正在安装中" && $osapt install socat)

function main_menu(){
    clear
    red "=================================="
    echo "                           "
    red "    Acme.sh 域名证书一键申请脚本     "
    red "          by 小御坂的破站           "
    echo "                           "
    red "  Site: https://blog.misaka.rest  "
    echo "                           "
    red "=================================="
    echo "                           "
    echo "                           "
    echo "1. 申请证书"
    echo "2. 续期证书"
    echo "v. 更新脚本"
    echo "0. 退出脚本"
    echo "                           "
    echo "                           "
    read -p "请输入选项：" menuNumberInput
    case "$menuNumberInput" in
        0 ) exit 0
    esac
}

main_menu