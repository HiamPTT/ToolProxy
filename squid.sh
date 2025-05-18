clear
echo -e "Start Install Squid Proxy ..."
usernamesquid="$1"
passwordsquid="$2"
if [ "$(whoami)" != "root" ]; then
    echo "ERROR: You need to run the script as user root or add sudo before command."
    exit 1
fi

apt install wget -y
/usr/bin/wget -q --no-check-certificate -O /usr/local/bin/sok-find-os https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/sok-find-os.sh > /dev/null 2>&1
chmod 755 /usr/local/bin/sok-find-os

/usr/bin/wget -q --no-check-certificate -O /usr/local/bin/squid-uninstall https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid-uninstall.sh > /dev/null 2>&1
chmod 755 /usr/local/bin/squid-uninstall

/usr/bin/wget -q --no-check-certificate -O /usr/local/bin/squid-add-user https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid-add-user.sh > /dev/null 2>&1
chmod 755 /usr/local/bin/squid-add-user

if [[ -d /etc/squid/ || -d /etc/squid3/ ]]; then
    echo "Squid Proxy đã được cài đặt. Nếu bạn muốn cài đặt lại, trước tiên hãy gỡ cài đặt proxy bằng cách chạy lệnh: squid-uninstall"
    exit 1
fi

if [ ! -f /usr/local/bin/sok-find-os ]; then
    echo "/usr/local/bin/sok-find-os not found"
    exit 1
fi

SOK_OS=$(/usr/local/bin/sok-find-os)

if [ "$SOK_OS" == "ERROR" ]; then
    echo "OS NOT SUPPORTED."
    exit 1
fi

if [ "$SOK_OS" == "ubuntu2204" ]; then
    /usr/bin/apt update > /dev/null 2>&1
    /usr/bin/apt -y install apache2-utils squid > /dev/null 2>&1
    touch /etc/squid/passwd
    mv /etc/squid/squid.conf /etc/squid/squid.conf.bak 2>/dev/null || true
    /usr/bin/touch /etc/squid/blacklist.acl
    /usr/bin/wget -q --no-check-certificate -O /etc/squid/squid.conf https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/conf/ubuntu-2204.conf
    if [ -f /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp --dport 3128 -j ACCEPT
        /sbin/iptables-save
    fi
    service squid restart
    systemctl enable squid
elif [ "$SOK_OS" == "centos7" ]; then
    yum install squid httpd-tools -y
    /bin/rm -f /etc/squid/squid.conf
    /usr/bin/touch /etc/squid/blacklist.acl
    /usr/bin/wget -q --no-check-certificate -O /etc/squid/squid.conf https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/conf/squid-centos7.conf
    systemctl enable squid
    systemctl restart squid
    if [ -f /usr/bin/firewall-cmd ]; then
        firewall-cmd --zone=public --permanent --add-port=3128/tcp > /dev/null 2>&1
        firewall-cmd --reload > /dev/null 2>&1
    fi
fi

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${NC}"
echo -e "${GREEN}Squid Proxy Install Successfully.${NC}"
echo -e "${NC}"
/usr/bin/htpasswd -b -c /etc/squid/passwd "$usernamesquid" "$passwordsquid"
echo -e "${GREEN}Add Account ${usernamesquid}|${passwordsquid} Successfully.${NC}"
sleep 1
cd ~
clear
echo -e "Install Squid Proxy Success"
