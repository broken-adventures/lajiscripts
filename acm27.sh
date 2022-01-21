#!/usr/bin/env bash

red(){
    echo -e "\033[31m\033[01m$1\033[0m";
}

green(){
    echo -e "\033[32m\033[01m$1\033[0m";
}

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m";
}

white(){
    echo -e "\033[37m\033[01m$1\033[0m";
}

[[ $EUID -ne 0 ]] && yellow "请在root用户下运行脚本" && exit 1

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
    red "不支持当前系统，请使用Ubuntu，Debian，Centos系统" && exit 1    
fi

function checkwarp(){
    green "正在检测WARP状态（本脚本只支持fscarmen的warp脚本检测并自动开关闭）"
    if [[ -n $(wg) ]]; then
        if warp h; then
            warp o
            yellow "检测到你使用的是fscarmen的脚本并启用WARP，已为你自动关闭WARP"
        else
            red "检测到WARP已开启，但是我没办法调用你所使用的脚本自动关闭WARP，请自行去你所使用的脚本处关闭WARP"
        fi
    fi
}

function checktls(){
    if [[ -f /root/cert.crt && -f /root/private.key ]]; then
        if [[ -s /root/cert.crt && -s /root/private.key ]]; then
            green "证书申请成功！证书（cert.crt）和私钥（private.key）已保存到 /root 文件夹" 
            yellow "证书crt路径如下：/root/cert.crt"
            yellow "私钥key路径如下：/root/private.key"
            exit 0
        else
            red "遗憾，证书申请失败"
            green "建议如下："
            yellow "1. 检测防火墙是否打开"
            yellow "2. 检查80端口是否被占用（先lsof -i :80 后kill -9 进程id）"
            yellow "3. 更换域名再尝试执行脚本"
            yellow "4. 关闭WARP"
            exit 0
        fi
    fi
}

function acme(){   
    green "正在安装依赖及acme.sh……"
    [[ $(type -P yum) ]] && yumapt='yum -y' || yumapt='apt -y'
    [[ $(type -P curl) ]] || $yumapt update;$yumapt install curl
    [[ $(type -P socat) ]] || $yumapt install socat
    [[ $(type -P binutils) ]] || $yumapt install binutils
    checkwarp
    v6=`curl -s6m2 https://ip.gs`
    v4=`curl -s4m2 https://ip.gs`
    if [ -z $v4 ]; then
        echo -e "nameserver 2001:67c:2b0::4\nnameserver 2001:67c:2b0::6" > /etc/resolv.conf
    fi
    read -p "请输入注册邮箱（例：admin@bilibili.com，或留空自动生成）：" acmeEmail
    if [ -z $acmeEmail ]; then
        autoEmail=`head -n 20 /dev/urandom | sed 's/[^a-z]//g' | strings -n 4 | tr '[:upper:]' '[:lower:]' | head -1`
        acmeEmail=$autoEmail@gmail.com
        yellow "检测到你未输入邮箱，脚本已为你自动生成一个邮箱：$acmeEmail"
    fi
    curl https://get.acme.sh | sh -s email=$acmeEmail
    source ~/.bashrc
    bash /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    read -p "请输入解析完成的域名:" domain
    green "已输入的域名:$domain" && sleep 1
    domainIP=$(curl -s ipget.net/?ip="cloudflare.1.1.1.1.$domain")
    if [[ -n $(echo $domainIP | grep nginx) ]]; then
    domainIP=$(curl -s ipget.net/?ip="$domain")
        if [[ $domainIP = $v4 ]]; then
            yellow "当前域名解析的IPV4：$domainIP" && sleep 1
            bash /root/.acme.sh/acme.sh  --issue -d ${domain} --standalone -k ec-256 --server letsencrypt --force
        fi
        if [[ $domainIP = $v6 ]]; then
            yellow "当前域名解析的IPV6：$domainIP" && sleep 1
            bash /root/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --server letsencrypt --force --listen-v6
        fi
        if [[ -n $(echo $domainIP | grep nginx) ]]; then
            yellow "域名解析无效，请检查域名是否填写正确或等待解析完成再执行脚本"
            exit 0
        elif [[ -n $(echo $domainIP | grep ":") || -n $(echo $domainIP | grep ".") ]]; then
            if [[ $domainIP != $v4 ]] && [[ $domainIP != $v6 ]]; then
            red "当前域名解析的IP与VPS的IP不匹配"
            green "建议如下："
            yellow "1、请确保Cloudflare小云朵为关闭状态(仅限DNS)"
            yellow "2、请检查域名解析网站设置的IP是否正确"
            exit 0
            fi
        fi
        else
        read -p "当前为泛域名申请证书，请输入Cloudflare Global API Key:" GAK
        export CF_Key="$GAK"
        read -p "当前为泛域名申请证书，请输入Cloudflare登录邮箱：" CFemail
        export CF_Email="$CFemail"
        if [[ $domainIP = $v4 ]]; then
            yellow "当前泛域名解析的IPV4：$domainIP" && sleep 1
            bash /root/.acme.sh/acme.sh --issue --dns dns_cf -d ${domain} -d *.${domain} -k ec-256 --server letsencrypt
        fi
        if [[ $domainIP = $v6 ]]; then
            yellow "当前泛域名解析的IPV6：$domainIP" && sleep 1
            bash /root/.acme.sh/acme.sh --issue --dns dns_cf -d ${domain} -d *.${domain} -k ec-256 --server letsencrypt --listen-v6
        fi
    fi
    bash /root/.acme.sh/acme.sh --install-cert -d ${domain} --key-file /root/private.key --fullchain-file /root/cert.crt --ecc
    checktls
    exit 0
}

function certificate(){
    [[ -z $(/root/.acme.sh/acme.sh -v 2>/dev/null) ]] && yellow "未安装acme.sh无法执行" && exit 0
    bash /root/.acme.sh/acme.sh --list
    read -p "请输入要撤销的域名证书（复制Main_Domain下显示的域名）:" domain
    if [[ -n $(bash /root/.acme.sh/acme.sh --list | grep $domain) ]]; then
        bash /root/.acme.sh/acme.sh --revoke -d ${domain} --ecc
        bash /root/.acme.sh/acme.sh --remove -d ${domain} --ecc
        green "撤销并删除${domain}域名证书成功"
        exit 0
    else
        red "未找到你输入的${domain}域名证书，请自行检查！"
        exit 0
    fi
}

function acmerenew(){
    [[ -z $(/root/.acme.sh/acme.sh -v) ]] && yellow "未安装acme.sh无法执行" && exit 0
    bash /root/.acme.sh/acme.sh --list
    read -p "请输入要续期的域名证书（复制Main_Domain下显示的域名）:" domain
    if [[ -n $(bash /root/.acme.sh/acme.sh --list | grep $domain) ]]; then
        checkwarp
        bash /root/.acme.sh/acme.sh --renew -d ${domain} --force --ecc
        checktls
        exit 0
    else
        red "未找到你输入的${domain}域名证书，请再次检查域名输入正确"
        exit 0
    fi
}

function menu(){
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
    green "0. 退出"
    echo "         "
    read -p "请输入数字:" NumberInput
    case "$NumberInput" in     
        1 ) acme;;
        2 ) certificate;;
        3 ) acmerenew;;
        4 ) checkwarp;;
        0 ) exit 0    
    esac
}

menu
