#!/bin/bash
# ============================
# Jenkins Auto Installation Script
# Author: Afaf Adel
# ============================

echo "🔹 Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "🔹 Installing Java (required for Jenkins)..."
sudo apt install openjdk-17-jdk -y

echo "✅ Java installed:"
java -version

echo "🔹 Adding Jenkins repository and key..."
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian/ binary/ > /etc/apt/sources.list.d/jenkins.list'

echo "🔹 Installing Jenkins..."
sudo apt update -y
sudo apt install jenkins -y

echo "🔹 Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "✅ Checking Jenkins status..."
sudo systemctl status jenkins | grep Active

echo "🔹 Configuring Jenkins to run on all IP addresses..."
sudo sed -i 's/HTTP_HOST=.*/HTTP_HOST=0.0.0.0/' /etc/default/jenkins

echo "🔹 Restarting Jenkins service..."
sudo systemctl restart jenkins

# عرض IP address
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "=========================================="
echo "✅ Jenkins installation completed!"
echo "🔹 Access Jenkins from:  http://$IP_ADDR:8080"
echo "🔹 To unlock Jenkins, use this password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "=========================================="

echo "🔹 Opening firewall for port 8080..."
sudo ufw allow 8080
sudo ufw reload

echo "✅ Jenkins is ready and running on IP: $IP_ADDR"
