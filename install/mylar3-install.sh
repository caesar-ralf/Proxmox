#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: caesar-ralf (caesar-ralf)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
msg_ok "Installed Dependencies"

msg_info "Updating Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-pip
msg_ok "Updated Python3"

msg_info "Installing Mylar3"
mkdir -p /var/lib/mylar3/
wget -q https://github.com/mylar3/mylar3/archive/refs/heads/master.zip
unzip -qq master -d /tmp/
mv /tmp/mylar3-master /opt/mylar3/
chmod 775 /opt/mylar3 /var/lib/mylar3/
python3 -m pip install -q -r /opt/mylar3/requirements.txt
msg_ok "Installed Mylar3"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/mylar3.service
[Unit]
Description=Mylar3 Daemon
After=syslog.target network.target

[Service]
WorkingDirectory=/opt/mylar3/
UMask=0002
Restart=on-failure
RestartSec=5
Type=simple
ExecStart=/usr/bin/python3 /opt/mylar3/Mylar.py
KillSignal=SIGINT
TimeoutStopSec=20
SyslogIdentifier=mylar3

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now mylar3
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf master.zip
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"