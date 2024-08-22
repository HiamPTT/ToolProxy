#!/bin/bash

# Cập nhật hệ thống và cài đặt dante-server
sudo apt update
sudo apt install dante-server -y

# Tạo người dùng và đặt mật khẩu
sudo useradd -m aqiang
echo "aqiang:147369" | sudo chpasswd

# Cấu hình Dante server
cat <<EOF | sudo tee /etc/danted.conf
logoutput: syslog

internal: 0.0.0.0 port = 1080
external: eth0

method: username

user.privileged: root
user.notprivileged: nobody
user.libwrap: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
    method: username
    username: aqiang
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
    method: username
    username: aqiang
}
EOF

# Khởi động lại dịch vụ Dante
sudo systemctl restart danted
sudo systemctl enable danted

# Mở cổng 1080 nếu UFW đang chạy
if sudo ufw status | grep -q "active"; then
    sudo ufw allow 1080/tcp
fi

echo "Proxy SOCKS5 đã được cài đặt thành công!"
