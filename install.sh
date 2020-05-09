#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

# notification information
Info="${Green}[信息]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[错误]${Font}"

# variables
shell_version="1.0.0"
github_branch="master"
version_cmp="/tmp/version_cmp.tmp"
nginx_conf_dir="/etc/nginx/conf/conf.d"

# functions
is_root() {
    if [ 0 == $UID ]; then
        echo -e "${OK} ${GreenBG} 当前用户是root用户，进入安装流程 ${Font}"
        sleep 3
    else
        echo -e "${Error} ${RedBG} 当前用户不是root用户，请切换到root用户后重新执行脚本 ${Font}"
        exit 1
    fi
}

judge() {
    if [[ 0 -eq $? ]]; then
        echo -e "${OK} ${GreenBG} $1 完成 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} $1 失败${Font}"
        exit 1
    fi
}

read_your_settings(){
    read -rp "请输入你的网站代号:"  site_name
    nginx_conf="${nginx_conf_dir}/${site_name}.conf"
}

install_or_upgrade_website() {
    mkdir -p /home/wwwroot
    cd /home/wwwroot || exit
    rm -rf /home/wwwroot/daminggong.net
    git clone https://github.com/huobazi/daminggong.net
    judge "website clone "
}

modify_nginx_root() {
    set -i "/root/c \\\t root /home/wwwroot/daminggong.net;" ${nginx_conf}
    judge "配置 Nginx "
}

update_sh() {
    old_version=$(curl -L -s https://raw.githubusercontent.com/huobazi/daminggong.net/${github_branch}/install.sh | grep "shell_version=" | head -1 | awk -F '=|"' '{print $3}')
    echo "$old_version" >$version_cmp
    echo "$shell_version" >>$version_cmp
    if [[ "$shell_version" < "$(sort -rV $version_cmp | head -1)" ]]; then
        echo -e "${OK} ${GreenBG} 存在新版本，是否更新 [Y/N]? ${Font}"
        read -r update_confirm
        case $update_confirm in
        [yY][eE][sS] | [yY])
            wget -N --no-check-certificate https://raw.githubusercontent.com/huobazi/daminggong.net/${github_branch}/install.sh
            echo -e "${OK} ${GreenBG} 更新完成 ${Font}"
            exit 0
            ;;
        *) ;;

        esac
    else
        echo -e "${OK} ${GreenBG} 当前版本为最新版本 ${Font}"
    fi
}

restart_nginx(){
    systemctl restart nginx
    judge "Nginx 重启"
}

menu() {
    update_sh

    echo -e " Daminggong.net 网站安装管理脚本 ${Red}[${shell_version}]${Font}"
    echo -e " --- Authored by Marble --- "
    echo -e " https://github.com/huobazi\n"
    echo -e " —————————————— 安装向导 ——————————————"""
    echo -e " ${Green}0.${Font}  升级安装脚本"
    echo -e " ${Green}1.${Font}  安装"
    echo -e " ${Green}99.${Font} 退出 \n"

    read -rp "请输入数字：" menu_num
    case $menu_num in
    0)
        update_sh
        ;;
    1)
        read_your_settings
        install_or_upgrade_website
        modify_nginx_root
        restart_nginx
        ;;
    99)
        exit 0
        ;;
    *)
        echo -e "${RedBG}请输入正确的数字${Font}"
        ;;
    esac
}

menu