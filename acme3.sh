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

function acme() {
	systemctl stop nginx >/dev/null 2>&1
	wg-quick down wgcf >/dev/null 2>&1
	v6=$(curl -s6m3 https://ip.gs -k)
	v4=$(curl -s4m3 https://ip.gs -k)
	[[ $(type -P curl) ]] || $yumapt update
	$yumapt install curl
	[[ $(type -P socat) ]] || $yumapt install socat
	curl https://get.acme.sh | sh
    read -p "请输入需要注册的邮箱：" registerEmail
	bash /root/.acme.sh/acme.sh --register-account -m $registerEmail
	read -p "请输入解析完成的域名:" domain
	green "已输入的域名:$domain"
	domainIP=$(curl -s ipget.net/?ip="$domain")
	[[ $domainIP == $v4 ]] && yellow "当前二级域名解析到的IPV4：$domainIP" && bash /root/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --server letsencrypt && tls
	[[ $domainIP == $v6 ]] && yellow "当前二级域名解析到的IPV6：$domainIP" && bash /root/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --server letsencrypt --listen-v6 && tls
	[[ -n $(echo $domainIP | grep nginx) ]] && yellow "域名解析无效，请检查二级域名是否填写错误或稍等几分钟等待解析完成再执行脚本"
	if [[ -n $(echo $domainIP | grep ":") || -n $(echo $domainIP | grep ".") ]]; then
		if [[ $domainIP != $v4 ]] || [[ $domainIP != $v6 ]]; then
			red "当前二级域名解析的IP与当前VPS使用的IP不匹配"
			green "建议如下："
			yellow "1、请确保Cloudflare小黄云关闭（仅限DNS）状态"
			yellow "2、请检查域名解析网站设置的IP是否正确"
		fi
	fi
	tls() {
		bash /root/.acme.sh/acme.sh --installcert -d ${domain} --key-file /root/private.key --fullchain-file /root/cert.crt --ecc
		[[ -f /root/cert.crt && -f /root/private.key ]] && green "恭喜，tls证书申请成功！域名证书（cert.crt）和私钥（private.key）已保存到 /root 文件夹" || red "遗憾，tls证书申请失败，请查看80端口是否被占用（先lsof -i :80 后kill -9 进程id）或者更换下二级域名称再尝试执行脚本！"
	}
	wg-quick up wgcf >/dev/null 2>&1
	systemctl start nginx >/dev/null 2>&1
}

function renew(){
    read -p "你的域名:" domain
    bash /root/.acme.sh/acme.sh --renew -d ${domain} --force --ecc
}

function start_menu(){
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
    read -p "请输入数字:" menuNumberInput
    case "$menuNumberInput" in     
        1 ) acme ;;
        2 ) renew ;;
        0 ) exit 0
    ;;       
    esac
}   

start_menu