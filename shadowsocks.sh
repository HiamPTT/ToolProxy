#!/bin/bash

echo -e "Start Install ShadowSocks ..."
PASS=$1

# Cài đặt Shadowsocks
sudo apt-get install -y shadowsocks-libev

# Tạo file cấu hình với password từ tham số
cat <<EOL | sudo tee /etc/shadowsocks-libev/config.json
{
    "server": "0.0.0.0",
    "server_port": 8686,
    "password": "$PASS",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305"
}
EOL

# Khởi động dịch vụ Shadowsocks
sudo systemctl start shadowsocks-libev
sudo systemctl enable shadowsocks-libev

echo "Shadowsocks đã được cài đặt thành công"
