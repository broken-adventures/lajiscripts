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

if [[ $(id -u) != 0 ]]; then
yellow " 请以root模式运行脚本"
exit 0
fi

[[ $(type -P yum) ]] && osapt='yum -y' || osapt='apt -y'
[[ $(type -P curl) ]] || (yellow "curl未安装，正在安装中" && $osapt install curl)
[[ $(type -P socat) ]] || (yellow "socat未安装，正在安装中" && $osapt install curl)