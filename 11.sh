#!/bin/bash

# 一些全局变量
ver="1.5"
changeLog="重构脚本，详细内容可看Github项目的思维导图"
arch=`uname -m`
virt=`systemd-detect-virt`
kernelVer=`uname -r`

green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}

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
else 
    red "不支持你当前系统，请使用Ubuntu、Debian、Centos的主流系统"
    rm -f MisakaToolbox.sh
    exit 1
fi

if ! type curl >/dev/null 2>&1; then 
    yellow "curl未安装，安装中"
    if [ $release = "Centos" ]; then
        yum -y update && yum install curl -y
    else
        apt-get update -y && apt-get install curl -y
    fi	   
else
    green "curl已安装"
fi

if ! type wget >/dev/null 2>&1; then 
    yellow "wget未安装，安装中"
    if [ $release = "Centos" ]; then
        yum -y update && yum install wget -y
    else
        apt-get update -y && apt-get install wget -y
    fi	   
else
    green "wget已安装"
fi

if ! type sudo >/dev/null 2>&1; then 
    yellow "sudo未安装，安装中"
    if [ $release = "Centos" ]; then
        yum -y update && yum install sudo -y
    else
        apt-get update -y && apt-get install sudo -y
    fi	   
else
    green "sudo已安装"
fi

function updateScript(){

}

function menu(){
    clear
    red "============================"
    red "                            "
    red "    Misaka Linux Toolbox    "
    echo "                            "
    red "  https://blog.misaka.rest  "
    echo "                            "
    red "============================"
    echo "                            "
    green "检测到您当前运行的工具箱版本是：$ver"
    green "更新日志：$changeLog"
    echo "                            "
    yellow "检测到VPS信息如下"
    yellow "处理器架构：$arch"
    yellow "虚拟化架构：$virt"
    yellow "操作系统：$release"
    yellow "内核版本：$kernelVer"
    echo "                            "
    green "下面是脚本分类，请选择对应的分类后进入到相对应的菜单中"
    echo "                            "
    echo "1. 系统相关"
    echo "2. 面板相关"
    echo "3. 节点相关"
    echo "4. VPS测试"
    echo "5. VPS探针"
    echo "                            "
    echo "9. 更新脚本"
    echo "0. 退出脚本"
    echo "                            "
    read -p "请输入选项:" menuNumberInput
    case "$menuNumberInput" in
        1 ) page1 ;;
        2 ) page2 ;;
        3 ) page3 ;;
        4 ) page4 ;;
        5 ) page5 ;;
        9 ) updateScript ;;
        0 ) exit 0;;
    esac
}

function page1(){

}

function page2(){

}

function page3(){

}

function page4(){

}

function page5(){

}

menu