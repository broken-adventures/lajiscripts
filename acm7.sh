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
    red "不支持你当前系统，请选择使用Ubuntu,Debian,Centos系统" && exit 1    
fi

function checktls(){
    if [[ -f /root/cert.crt && -f /root/private.key ]]; then
        if [[ -s /root/cert.crt && -s /root/private.key ]]; then
            green "域名证书申请成功！域名证书（cert.crt）和私钥（private.key）已保存到 /root 文件夹" 
            yellow "证书crt路径如下："
            green "/root/cert.crt"
            yellow "私钥key路径如下："
            green "/root/private.key"
            exit 0
        else
            red "遗憾，域名证书申请失败"
            green "建议如下（按顺序）："
            yellow "1、检测防火墙是否打开"
            yellow "2、请查看80端口是否被占用（先lsof -i :80 后kill -9 进程id）"
            yellow "3、更换下二级域名名称再尝试执行脚本"
            yellow "4. 关闭nginx等网站运行环境"
            yellow "5. 关闭WARP"
            exit 0
        fi
    fi
}

function acme(){   
    green "安装依赖及acme……"
    [[ $(type -P yum) ]] && yumapt='yum -y' || yumapt='apt -y'
    [[ $(type -P curl) ]] || $yumapt update;$yumapt install curl
    [[ $(type -P socat) ]] || $yumapt install socat
    [[ $(type -P binutils) ]] || $yumapt install binutils
    v6=$(curl -s6m3 https://ip.gs)
    v4=$(curl -s4m3 https://ip.gs)
    read -p "请输入你注册的邮箱：" acmeEmail
    curl https://get.acme.sh | sh -s email=$acmeEmail@gmail.com
    source ~/.bashrc
    bash /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    read -p "请输入解析完成的域名:" domain
    green "已输入的域名:$domain" && sleep 1
    domainIP=$(curl -s ipget.net/?ip="cloudflare.1.1.1.1.$domain")
    if [[ -n $(echo $domainIP | grep nginx) ]]; then
    domainIP=$(curl -s ipget.net/?ip="$domain")
        if [[ $domainIP = $v4 ]]; then
            yellow "当前二级域名解析到的IPV4：$domainIP" && sleep 1
            bash /root/.acme.sh/acme.sh  --issue -d ${domain} --standalone -k ec-256 --server letsencrypt
        fi
        if [[ $domainIP = $v6 ]]; then
            yellow "当前二级域名解析到的IPV6：$domainIP" && sleep 1
            bash /root/.acme.sh/acme.sh  --issue -d ${domain} --standalone -k ec-256 --server letsencrypt --listen-v6
        fi
        if [[ -n $(echo $domainIP | grep nginx) ]]; then
            yellow "域名解析无效，请检查二级域名是否填写正确或稍等几分钟等待解析完成再执行脚本"
            exit 0
        elif [[ -n $(echo $domainIP | grep ":") || -n $(echo $domainIP | grep ".") ]]; then
            if [[ $domainIP != $v4 ]] && [[ $domainIP != $v6 ]]; then
            red "当前二级域名解析的IP与当前VPS使用的IP不匹配"
            green "建议如下："
            yellow "1、请确保Cloudflare小黄云关闭状态(仅限DNS)，其他域名解析网站设置同理"
            yellow "2、请检查域名解析网站设置的IP是否正确"
            exit 0
            fi
        fi
        else
        read -p "当前为泛域名申请证书，请复输入loudflare Global API Key:" GAK
        export CF_Key="$GAK"
        read -p "当前为泛域名申请证书，请输入Cloudflarer的登录邮箱：" CFemail
        export CF_Email="$CFemail"
        if [[ $domainIP = $v4 ]]; then
            yellow "当前泛域名解析到的IPV4：$domainIP" && sleep 1
            bash /root/.acme.sh/acme.sh --issue --dns dns_cf -d ${domain} -d *.${domain} -k ec-256 --server letsencrypt
        fi
        if [[ $domainIP = $v6 ]]; then
            yellow "当前泛域名解析到的IPV6：$domainIP" && sleep 1
            bash /root/.acme.sh/acme.sh --issue --dns dns_cf -d ${domain} -d *.${domain} -k ec-256 --server letsencrypt --listen-v6
        fi
    fi
    bash /root/.acme.sh/acme.sh --install-cert -d ${domain} --key-file /root/private.key --fullchain-file /root/cert.crt --ecc
    checktls
    exit 0
}

function Certificate(){
    [[ -z $(acme.sh -v 2>/dev/null) ]] && yellow "未安装acme.sh无法执行" && exit 0
    bash /root/.acme.sh/acme.sh --list
    read -p "请输入要撤销并删除的域名证书（复制Main_Domain下显示的域名）:" domain
    if [[ -n $(bash /root/.acme.sh/acme.sh --list | grep $domain) ]]; then
        bash /root/.acme.sh/acme.sh --revoke -d ${domain} --ecc
        bash /root/.acme.sh/acme.sh --remove -d ${domain} --ecc
        green "撤销并删除${domain}域名证书成功"
        exit 0
    else
        red "未找到你输入的${domain}域名证书，请自行核实！"
        exit 0
    fi
}

function acmerenew(){
    [[ -z $(acme.sh -v) ]] && yellow "未安装acme.sh无法执行" && exit 0
    bash /root/.acme.sh/acme.sh --list
    read -p "请输入要续期的域名证书（复制Main_Domain下显示的域名）:" domain
    if [[ -n $(bash /root/.acme.sh/acme.sh --list | grep $domain) ]]; then
        bash /root/.acme.sh/acme.sh --renew -d ${domain} --force --ecc
        checktls
        exit 0
    else
        red "未找到你输入的${domain}域名证书，请再次检查域名输入正确"
        exit 0
    fi
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
    green "1.  首次申请证书（自动识别单域名与泛域名）"
    green "2.  查询、撤销并删除当前已申请的域名证书"
    green "3.  手动续期域名证书"
    green "0.  退出"
    echo "         "
    read -p "请输入数字:" NumberInput
    case "$NumberInput" in     
        1 ) acme;;
        2 ) Certificate;;
        3 ) acmerenew;;
        0 ) exit 0    
    esac
}

start_menu
