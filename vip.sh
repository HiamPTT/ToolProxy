#!/bin/bash

# Tên tệp: vip.sh
# Mô tả: Script để cài đặt Squid Proxy và WireGuard trên Ubuntu 22.04
# Yêu cầu người dùng cung cấp tên người dùng và mật khẩu cho Squid Proxy từ dòng lệnh

# Kiểm tra số lượng tham số đầu vào
if [ "$#" -ne 2 ]; then
    echo "Sử dụng: $0 <squid_user> <squid_pass>"
    exit 1
fi

# Lấy tham số đầu vào
SQUID_USER=$1
SQUID_PASS=$2

# Cài đặt các thư viện cần thiết
echo "Cài đặt các thư viện cần thiết..."
sudo apt-get update
sudo apt-get install -y qrencode imagemagick

# Tạo thư mục cấu hình nếu chưa tồn tại
sudo mkdir -p /etc/wireguard

# Tắt các thông báo tương tác và không yêu cầu xác nhận
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y debconf-utils
echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | sudo debconf-set-selections

# Bỏ qua các thông báo về các dịch vụ sử dụng thư viện lỗi thời
sudo sed -i '/^Unattended-Upgrade::Auto-Upgrade-Enabled/d' /etc/apt/apt.conf.d/20auto-upgrades
sudo sed -i '/^APT::Periodic::Update-Package-Lists/d' /etc/apt/apt.conf.d/10periodic

# Hàm để cài đặt Squid Proxy
function installsquid() {
    echo "Bắt đầu cài đặt Squid Proxy..."

    # Tải xuống script cài đặt Squid Proxy
    wget https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid3-install.sh -O squid3-install.sh
    
    # Cấp quyền thực thi cho script cài đặt
    chmod +x squid3-install.sh
    
    # Chạy script cài đặt Squid Proxy
    sudo bash squid3-install.sh

    # Thêm người dùng vào Squid Proxy mà không yêu cầu nhập thông tin
    echo "Thêm người dùng vào Squid Proxy với tên người dùng: $SQUID_USER và mật khẩu đã nhập..."
    echo "$SQUID_USER:$SQUID_PASS" | sudo squidpasswd /etc/squid/passwd
    
    echo "Cài đặt Squid Proxy hoàn tất!"
}

# Hàm để cài đặt WireGuard
function installwireguard() {
    echo "Bắt đầu cài đặt WireGuard..."

    # Tải xuống script cài đặt WireGuard
    wget https://git.io/wireguard -O wireguard-install.sh
    
    # Cấp quyền thực thi cho script cài đặt
    chmod +x wireguard-install.sh
    
    # Chạy script cài đặt WireGuard với các tùy chọn tự động
    echo "Cài đặt WireGuard với DNS của Google, port 3128 và tên client là client..."
    echo -e "3128\n2\nclient\n" | sudo bash wireguard-install.sh

    # Đợi một chút để đảm bảo WireGuard được cấu hình hoàn tất
    sleep 10
    
    # Tạo mã QR từ tệp cấu hình và lưu vào /etc/qrcode.png
    echo "Tạo mã QR từ tệp cấu hình client và lưu vào /etc/qrcode.png..."
    if [ -f /root/client.conf ]; then
        sudo qrencode -t png -o /etc/qrcode.png < /root/client.conf
        echo "Mã QR đã được tạo và lưu tại /etc/qrcode.png."
        echo "Bạn có thể xem mã QR bằng cách mở tệp này hoặc sử dụng lệnh:"
        echo "sudo cat /etc/qrcode.png | display"  # Cần cài đặt `imagemagick` để sử dụng lệnh này

        # Hiển thị nội dung của tệp cấu hình client
        echo "Nội dung tệp cấu hình client:"
        cat /root/client.conf
        
        # Upload mã QR lên server
        echo "Đang upload mã QR lên server..."
        curl -F "file=@/etc/qrcode.png" https://proxy.vncloud.net/upload.php || echo "Upload không thành công!"

        echo "Upload mã QR lên server hoàn tất!"
    else
        echo "Tệp cấu hình client không tồn tại!"
        exit 1
    fi
    
    # Khởi động dịch vụ WireGuard nếu không được khởi động
    echo "Khởi động dịch vụ WireGuard..."
    sudo systemctl enable wg-quick@wg0
    sudo systemctl start wg-quick@wg0

    echo "Cài đặt WireGuard hoàn tất!"
}

# Cài đặt Squid Proxy
installsquid

# Cài đặt WireGuard
installwireguard

echo "Cảm ơn bạn đã sử dụng script cài đặt này!"
