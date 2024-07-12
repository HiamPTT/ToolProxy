
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
purple(){
    echo -e "\033[35m\033[01m$1\033[0m"
}

#cài đặt Squid Proxy
function installsquid(){
apt-get update
wget https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid3-install.sh -O squid3-install.sh
sudo bash squid3-install.sh
squid-add-user
red "đã cài đặt thành công Squid Proxy"
}

#restart Squid Proxy
function restartsquid(){
sudo systemctl restart squid.service
red "đã khởi động lại Squid Proxy"
}

#cài đặt Wireguard
function installwireguard(){
wget https://git.io/wireguard -O wireguard-install.sh && bash wireguard-install.sh
red "đã cài đặt thành công Wireguard"
}

#restart Wireguard
function restartwireguard(){
sudo systemctl restart wg-quick@wg0
red "đã khởi động lại Wireguard"
}

#check Squid Proxy
function checksquid(){
sudo systemctl status squid.service
}

#check Wireguard
function checkwireguard(){
sudo systemctl status wg-quick@wg0
}

#qr
function qr(){
qrencode -o /etc/qrcode.png -t PNG < /root/client.conf
curl -X POST --insecure -F "file=@/etc/qrcode.png" "https://proxy.vncloud.net/upload.php"
}

#Menu lệnh
function start_menu() {
    clear
    red "Tool PROXY Design Bởi PTT"
    red "Zalo: 0382.399.633 - 055.987.3663"
    yellow " ————————————————————————————————————————————————"
    green "1. Cài đặt Squid Proxy"
    green "2. Khởi động lại Squid Proxy"
    green "3. Cài đặt Wire Guard"
    green "4. Khởi động lại Wire Guard"
    green "5. Kiểm tra trạng thái Squid Proxy"
    green "6. Kiểm tra trạng thái Wire Guard"
    green "7. Tạo QR"
    green "8. Thoát Menu Tool"
    
    echo
    read -p "Vui lòng ấn số và Enter để chọn chức năng:" menuNumberInput
    case "$menuNumberInput" in
        1 )
           installsquid
	      ;;
        2 )
           restartsquid
        ;;
        3 )
           installwireguard
        ;;
        4 )
           restartwireguard
  	    ;;
        5 )
           checksquid
        ;;
        6 )
           checkwireguard
        ;;
	6 )
           qr
        ;;
        8 )
           exit 1
        ;;
        * )
            clear
            red "nhập đúng số đi sai rùi :)"
            start_menu
        ;;
    esac
}
start_menu "first"
