#!/bin/bash

IP=$(curl ipget.net)

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
    red "请在root用户下运行脚本"
    exit 0
fi

if [[ -f /etc/redhat-release ]]; then
    release="Centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
    release="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="Ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="Centos"
elif cat /proc/version | grep -q -E -i "debian"; then
    release="Debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="Ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="Centos"
fi	   

function acme(){
    if [ $release = "Centos" ]; then
        yum -y update && yum install curl -y && yum install -y socat 
    else
        apt update -y && apt install curl -y && apt install -y socat
    fi
    curl https://get.acme.sh | sh
    bash /root/.acme.sh/acme.sh --register-account -m xxxx@gmail.com
    read -p "你解析的域名:" domain
    domainIP=$(curl ipget.net/?ip="$domain")
    yellow "VPS本地IP：$IP"
    yellow "当前的域名解析到的IP：$domainIP"
    if echo $domainIP | grep -q ":"; then
        bash /root/.acme.sh/acme.sh  --issue -d ${domain} --standalone -k ec-256 --server letsencrypt --listen-v6
    else
        bash /root/.acme.sh/acme.sh  --issue -d ${domain} --standalone -k ec-256 --server letsencrypt
    fi
    bash /root/.acme.sh/acme.sh --installcert -d ${domain} --key-file /root/private.key --fullchain-file /root/cert.crt --ecc
}

function acmer(){
    read -p "你的域名:" domain
    bash /root/.acme.sh/acme.sh --renew -d ${domain} --force --ecc
}

function start_menu(){
    clear
    
    green " 1.  首次申请证书 "
    
    green " 2.  手动续期证书 "
    
    green " 0.  退出 "
    
read -p "请输入数字:" menuNumberInput
    case "$menuNumberInput" in     
        1 )
           acme
	;;
        2 )
           acmer
	;;
        0 )
           exit 1
    ;;       
 esac
}   
start_menu