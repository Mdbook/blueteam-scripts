#!/bin/bash
echo "Creating user..."
read -p "Username: " USER
/usr/sbin/useradd $USER
passwd $USER
usermod -aG sudo $USER
usermod -aG wheel $USER