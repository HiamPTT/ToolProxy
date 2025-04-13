#!/bin/bash

# Nhận tham số từ dòng lệnh
USER=$1
PASS=$2

# Cài đặt Shadowsocks
sudo apt-get update
sudo apt-get install -y shadowsocks-libev

# Tạo file cấu hình với username và password từ tham số
cat <<EOL | sudo tee /etc/shadowsocks-libev/config.json
{
    "server": "0.0.0.0",
    "server_port": 1080,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "$PASS",
    "timeout": 300,
    "method": "aes-256-cfb"
}
EOL

# Khởi động dịch vụ Shadowsocks
sudo systemctl start shadowsocks-libev
sudo systemctl enable shadowsocks-libev

# Kiểm tra trạng thái
sudo systemctl status shadowsocks-libev

echo "Shadowsocks đã được cài đặt và cấu hình với user: $USER và pass: $PASS"
