#!/bin/bash

# Cập nhật danh sách gói và cài đặt Shadowsocks-libev
echo "Cập nhật danh sách gói và cài đặt Shadowsocks-libev..."
sudo apt update
sudo apt install -y shadowsocks-libev

# Tạo tệp cấu hình cho Shadowsocks
CONFIG_FILE="/etc/shadowsocks-libev/config.json"
echo "Tạo tệp cấu hình Shadowsocks tại $CONFIG_FILE..."
sudo bash -c "cat > $CONFIG_FILE << EOF
{
    \"server\": \"0.0.0.0\",
    \"server_port\": 8388,
    \"local_port\": 1080,
    \"password\": \"147369\",
    \"timeout\": 300,
    \"method\": \"aes-256-gcm\",
    \"fast_open\": true
}
EOF"

# Tạo tệp cấu hình để hỗ trợ xác thực username/password
AUTH_CONFIG_FILE="/etc/shadowsocks-libev/auth.json"
echo "Tạo tệp cấu hình xác thực Shadowsocks tại $AUTH_CONFIG_FILE..."
sudo bash -c "cat > $AUTH_CONFIG_FILE << EOF
{
    \"aqiang\": \"147369\"
}
EOF"

# Cập nhật tệp cấu hình chính để sử dụng xác thực
sudo jq '. + { "auth": "/etc/shadowsocks-libev/auth.json" }' $CONFIG_FILE | sudo tee $CONFIG_FILE > /dev/null

# Khởi động dịch vụ Shadowsocks và thiết lập để khởi động cùng hệ thống
echo "Khởi động dịch vụ Shadowsocks và thiết lập để khởi động cùng hệ thống..."
sudo systemctl restart shadowsocks-libev
sudo systemctl enable shadowsocks-libev

# Kiểm tra trạng thái dịch vụ
echo "Kiểm tra trạng thái dịch vụ Shadowsocks..."
sudo systemctl status shadowsocks-libev

echo "Cài đặt và cấu hình Shadowsocks hoàn tất!"
