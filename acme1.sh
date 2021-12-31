#!/usr/bin/env bash

localIP = $(curl ipget.net)

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

function register(){
    curl https://get.acme.sh | sh
    read -p "请输入需要注册的邮箱：" registerEmail
    ~/.acme.sh/acme.sh --register-account -m $registerEmail
    green "请选择申请证书的方式："
    echo "1. 使用VPS空闲的80端口进行申请"
    echo "2. 配合Nginx申请"
    echo "                           "
    read -p "请输入选项：" registerInput
    case "$registerInput" in
        1 ) registerWith80 ;;
        2 ) registerWithNginx ;;
    esac
}

function registerWith80(){
    read -p "请输入需要申请证书的域名：" domainForSSL
    domainIP = $(curl ipget.net/?ip="$domainForSSL")
    if echo $localIP | grep -q ":"; then
        if [ $domainIP == $localIP ]
            bash /root/.acme.sh/acme.sh  --issue -d ${domainForSSL} --standalone -k ec-256 --server letsencrypt --listen-v6
            green "TLS证书已申请"
        else
            green "当前VPS IP：$localIP"
            red "域名的IP：$domainIP"
            echo "          "
            red "请检查域名是否正确解析到VPS，或者是CloudFlare的小云朵没点灭"
            exit 0
        fi
    else
        if [ $domainIP == $localIP ]
            bash /root/.acme.sh/acme.sh  --issue -d ${domainForSSL} --standalone -k ec-256 --server letsencrypt
            green "TLS证书已申请"
        else
            green "当前VPS IP：$localIP"
            red "域名的IP：$domainIP"
            echo "          "
            red "请检查域名是否正确解析到VPS，或者是CloudFlare的小云朵没点灭"
            exit 0
        fi
    fi
    read -p "请输入保存证书的绝对路径，例如：“/root”，路径的最后面不带/号：" saveCertPath
    ~/.acme.sh/acme.sh --installcert -d ${domainForSSL} --key-file ${saveCertPath}/private.key --fullchain-file ${saveCertPath}/cert.crt
    green "证书已保存到你指定的路径中"
}

function registerWithNginx(){

}

function renew(){

}

function upgrade(){

}

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