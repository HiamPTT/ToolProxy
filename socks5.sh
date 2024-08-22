#!/bin/bash

# Đảm bảo không có quy trình apt/dpkg nào đang chạy
while sudo fuser /var/lib/dpkg/lock-frontend > /dev/null 2>&1; do
    echo "Đang chờ khóa dpkg. Vui lòng đợi..."
    sleep 5
done

# Cập nhật hệ thống
sudo apt update
sudo apt upgrade -y

# Cài đặt Shadowsocks
sudo apt install -y shadowsocks-libev

# Tạo và cấu hình tập tin cấu hình
cat <<EOF | sudo tee /etc/shadowsocks-libev/config.json
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "147369",
    "timeout": 300,
    "method": "aes-256-gcm"
}
EOF

# Khởi động và kích hoạt dịch vụ Shadowsocks
sudo systemctl start shadowsocks-libev-server
sudo systemctl enable shadowsocks-libev-server

echo "Shadowsocks đã được cài đặt và cấu hình thành công!"
