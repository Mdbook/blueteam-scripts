#!/bin/bash
USER="none"
echo "Creating user..."
read -p "Username: " $USER
passwd $USER
usermod -aG sudo $USER
usermod -aG wheel $USER