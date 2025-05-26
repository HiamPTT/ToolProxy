#!/bin/bash

# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Gỡ Docker cũ (nếu có)
sudo apt remove -y docker docker-engine docker.io containerd runc

# Cài các gói phụ trợ cần thiết
sudo apt install -y ca-certificates curl gnupg lsb-release

# Tạo thư mục chứa khóa GPG
sudo mkdir -p /etc/apt/keyrings

# Tải khóa GPG chính thức từ Docker và lưu lại
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Thêm Docker repo chính thức
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Cập nhật lại danh sách gói
sudo apt update

# Cài Docker và các plugin
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Docker đã được cài đặt thành công!"
