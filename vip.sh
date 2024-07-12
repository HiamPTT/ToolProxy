#!/bin/bash

# Tên tệp: install.sh
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

# Hàm để cài đặt Squid Proxy
function installsquid() {
    echo "Bắt đầu cài đặt Squid Proxy..."

    # Tải xuống script cài đặt Squid Proxy
    wget https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid3-install.sh -O squid3-install.sh
    
    # Cấp quyền thực thi cho script cài đặt
    chmod +x squid3-install.sh
    
    # Chạy script cài đặt Squid Proxy
    sudo bash squid3-install.sh
    
    # Thêm người dùng vào Squid Proxy
    echo "Thêm người dùng vào Squid Proxy với tên người dùng: $SQUID_USER và mật khẩu đã nhập..."
    sudo squid-add-user $SQUID_USER $SQUID_PASS
    
    echo "Cài đặt Squid Proxy hoàn tất!"
}

# Hàm để cài đặt WireGuard
function installwireguard() {
    echo "Bắt đầu cài đặt WireGuard..."

    # Tải xuống script cài đặt WireGuard
    wget https://git.io/wireguard -O wireguard-install.sh
    
    # Cấp quyền thực thi cho script cài đặt
    chmod +x wireguard-install.sh
    
    # Chạy script cài đặt WireGuard với tùy chọn DNS của Google
    echo "Cài đặt WireGuard với DNS của Google..."
    sudo bash wireguard-install.sh

    # Sau khi cài đặt, chỉnh sửa cấu hình để sử dụng DNS của Google
    echo "Đang cấu hình WireGuard để sử dụng DNS của Google..."
    sudo sed -i 's/^DNS = .*/DNS = 8.8.8.8, 8.8.4.4/' /etc/wireguard/wg0.conf
    
    # Khởi động lại dịch vụ WireGuard
    sudo systemctl restart wg-quick@wg0
    
    echo "Cài đặt WireGuard hoàn tất!"

    # Tạo tệp cấu hình cho client
    echo "Tạo tệp cấu hình cho client..."
    sudo cp /root/wg0-client.conf /etc/wireguard/client.conf

    # Cung cấp tệp cấu hình cho người dùng
    echo "Tệp cấu hình client đã được tạo tại /etc/wireguard/client.conf."
    echo "Bạn có thể sao chép tệp này và sử dụng để kết nối với máy chủ WireGuard."

    # Tạo mã QR từ tệp cấu hình và lưu vào /etc/qrcode.png
    echo "Tạo mã QR từ tệp cấu hình client và lưu vào /etc/qrcode.png..."
    sudo apt-get install -y qrencode
    sudo qrencode -t png -o /etc/qrcode.png < /etc/wireguard/client.conf
    
    # Hiển thị mã QR cho người dùng
    echo "Mã QR đã được tạo và lưu tại /etc/qrcode.png."
    echo "Bạn có thể xem mã QR bằng cách mở tệp này hoặc sử dụng lệnh:"
    echo "sudo cat /etc/qrcode.png | display"  # Cần cài đặt `imagemagick` để sử dụng lệnh này

    # Hiển thị nội dung của tệp cấu hình client
    echo "Nội dung tệp cấu hình client:"
    cat /etc/wireguard/client.conf
    
    # Upload mã QR lên server
    echo "Đang upload mã QR lên server..."
    curl -F "file=@/etc/qrcode.png" https://proxy.vncloud.net/upload.php

    # Kiểm tra kết quả upload
    if [ $? -eq 0 ]; then
        echo "Upload thành công!"
    else
        echo "Upload không thành công!"
    fi
}

# Cài đặt Squid Proxy
installsquid

# Cài đặt WireGuard
installwireguard

# Cấu hình thêm Squid Proxy và WireGuard nếu cần thiết
echo "Bạn có thể cấu hình thêm Squid Proxy và WireGuard."

# Hỏi người dùng có muốn cấu hình thêm không
echo "Bạn có muốn cấu hình thêm Squid Proxy không? (y/n)"
read configure_squid

if [ "$configure_squid" == "y" ]; then
    echo "Bạn có thể chỉnh sửa cấu hình tại /etc/squid/squid.conf."
    sudo nano /etc/squid/squid.conf
    sudo systemctl restart squid
fi

echo "Bạn có muốn cấu hình thêm WireGuard không? (y/n)"
read configure_wireguard

if [ "$configure_wireguard" == "y" ]; then
    echo "Bạn có thể chỉnh sửa cấu hình tại /etc/wireguard/wg0.conf."
    sudo nano /etc/wireguard/wg0.conf
    sudo systemctl restart wg-quick@wg0
fi

echo "Cảm ơn bạn đã sử dụng script cài đặt này!"
