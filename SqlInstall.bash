#!/bin/bash

# این خط باعث می‌شود که اگر هر کدام از دستورات با خطا مواجه شدند، اسکریپت متوقف شود.
set -e

# افزودن کلید GPG
echo "Adding Microsoft GPG key..."
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

# افزودن مخزن MSSQL Server
echo "Adding MSSQL Server repository..."
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list)"

# بروزرسانی لیست بسته‌ها
echo "Updating package lists..."
sudo apt-get update

# نصب MSSQL Server
echo "Installing MSSQL Server..."
sudo apt-get install -y mssql-server

# پیکربندی MSSQL Server
echo "Configuring MSSQL Server..."
sudo /opt/mssql/bin/mssql-conf setup

# نمایش وضعیت MSSQL Server
echo "Checking status of MSSQL Server..."
systemctl status mssql-server --no-pager

# افزودن مخزن ابزارهای MSSQL
echo "Adding MSSQL tools repository..."
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

# بروزرسانی دوباره لیست بسته‌ها
echo "Updating package lists again..."
sudo apt-get update

# نصب ابزارهای MSSQL
echo "Installing MSSQL tools..."
sudo apt-get install mssql-tools18 unixodbc-dev

# بروزرسانی دوباره لیست بسته‌ها
echo "Updating package lists again..."
sudo apt-get update

# نصب دوباره ابزارهای MSSQL
echo "Installing MSSQL tools again..."
sudo apt-get install mssql-tools18

# افزودن ابزارهای MSSQL به PATH
echo "Updating PATH for MSSQL tools..."
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile
source ~/.bash_profile

echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc

echo "Installation completed successfully!"
