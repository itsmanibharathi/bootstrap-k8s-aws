#!/bin/bash

# Set hostname
hostnamectl set-hostname ${hostname}

# Set terminal environment
echo 'export TERM=xterm-256color' >> /etc/environment
echo 'export TERM=xterm-256color' >> /home/admin/.bashrc
echo 'export TERM=xterm-256color' >> /root/.bashrc

# Update system
apt-get update -y
apt-get upgrade -y

# Configure SSH for root login
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Set root password (change this in production)
echo 'root:admin123' | chpasswd

# Create SSH directory for root and copy authorized keys
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Copy admin user's SSH key to root
if [ -f /home/admin/.ssh/authorized_keys ]; then
    cp /home/admin/.ssh/authorized_keys /root/.ssh/
    chmod 600 /root/.ssh/authorized_keys
    chown root:root /root/.ssh/authorized_keys
fi

# Create a welcome message
cat > /etc/motd << EOF
Welcome to ${hostname}
Instance: ${instance_name}
Project: ${project_name}
Date: $(date)
EOF

# Enable clear screen functionality
echo 'alias cls="clear"' >> /root/.bashrc
echo 'alias cls="clear"' >> /home/admin/.bashrc

# Set up basic firewall rules (optional)
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh

# Reboot to apply all changes
reboot
