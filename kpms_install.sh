#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

# Import the Jitsi GPG key and add the Jitsi repository
curl https://download.jitsi.org/jitsi-key.gpg.key | gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg 
echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null

# Update and upgrade the system
apt update
apt upgrade -y

# Install required packages
apt install -y apt-transport-https mc curl gpg lsb-release dnsutils

# Get the server's IP address
ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')

# Display installation banner
echo "**********************************************************"
echo "*                    JITSI MEET INSTALL                   *"
echo "*           VPS, DEDICATED SERVERS, HOSTING              *"
echo "*          -- www.devchristiangonzales.com --            *"
echo "**********************************************************"
sleep 1

# Set Hostname
hostname="meet.kpms.cloud"
host=${hostname%.*.*.*}
echo -e "127.0.0.1\tlocalhost\n$ip\t$hostname\t$host" > /etc/hosts
hostnamectl set-hostname $host

# Check if the DNS record points to the server's IP
echo "Checking that $hostname is pointed to $ip"
dnscheck=$(dig +short A $hostname @8.8.8.8)
if [ "$dnscheck" != "$ip" ]; then
    echo "The DNS record does not exist, does not match the IP, or is not yet propagated in the DNS system."
    echo "Installation has been cancelled. Once the DNS record exists, run the installation again."
    exit 1
fi 

# Install Jitsi Meet
echo "The DNS record looks good, installation will continue."
sleep 5
apt install -y jitsi-meet

# Optionally install Let's Encrypt SSL certificate
# echo -e "your-email@example.com" | /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

# Installation complete message
echo "Installation complete. Please restart the server."
sleep 1
