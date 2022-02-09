#!/bin/bash

# 控制台字体
red(){
    echo -e "\033[31m\033[01m$1\033[0m";
}

green(){
    echo -e "\033[32m\033[01m$1\033[0m";
}

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m";
}

# 判断系统及定义系统安装依赖方式
REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "alpine")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Alpine")
PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update" "apk update -f")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "apk add -f")

# 判断是否为root用户
[[ $EUID -ne 0 ]] && yellow "请在root用户下运行脚本" && exit 1

# 检测系统，本部分代码感谢fscarmen的指导
CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')")

for i in "${CMD[@]}"; do
    SYS="$i" && [[ -n $SYS ]] && echo $SYS && break
done

for ((int=0; int<${#REGEX[@]}; int++)); do
    [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && [[ -n $SYSTEM ]] && break
done

[[ -z $SYSTEM ]] && red "不支持VPS的当前系统，请使用主流的操作系统" && exit 1

## 更新系统及安装系统依赖

${PACKAGE_UPDATE[int]}
${PACKAGE_INSTALL[int]} curl wget sudo socat binutils

## 检测warp状态

if [[ -n $(wg) ]]; then
    wg-quick down wgcf
fi

## 检测VPS IP地址
v6=`curl -s6m2 https://ip.gs || curl -s6m2 http://ipget.net`
v4=`curl -s4m2 https://ip.gs || curl -s4m2 http://ipget.net`

## 自动为IPv6 Only的机器设置DNS64服务器
if [ -z $v4 ]; then
    echo -e "nameserver 2001:67c:2b0::4\nnameserver 2001:67c:2b0::6" > /etc/resolv.conf
fi

menu(){
    clear
    red "=================================="
    echo "                           "
    red "    Acme.sh 域名证书一键申请脚本     "
    red "          by 小御坂的破站           "
    echo "                           "
    red "  Site: https://owo.misaka.rest  "
    echo "                           "
    red "=================================="
    echo "                           "
    green "1. 申请证书（自动识别单域名与泛域名）"
    green "2. 查询、撤销并删除当前已申请的域名证书"
    green "3. 手动续期域名证书"
    green "4. 更新脚本"
    green "0. 退出"
    echo "         "
    read -p "请输入数字:" NumberInput
    case "$NumberInput" in     
        1 ) acme;;
        2 ) certificate;;
        3 ) acmerenew;;
        4 ) upgrade ;;
        0 ) exit 0    
    esac
}