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

msg_info "Installing Kapowarr"
mkdir -p /var/lib/kapowarr/
wget -q https://github.com/Casvt/Kapowarr/archive/refs/tags/V1.0.0-beta-4.zip
unzip -qq V1.0.0-beta-4.zip -d /tmp/
mv /tmp/Kapowarr-1.0.0-beta-4 /opt/kapowarr/
chmod 775 /opt/kapowarr /var/lib/kapowarr/
python3 -m pip install -q -r /opt/kapowarr/requirements.txt
msg_ok "Installed Kapowarr"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/kapowarr.service
[Unit]
Description=Kapowarr Daemon
After=syslog.target network.target

[Service]
WorkingDirectory=/opt/kapowarr/
UMask=0002
Restart=on-failure
RestartSec=5
Type=simple
ExecStart=/usr/bin/python3 /opt/kapowarr/Kapowarr.py
KillSignal=SIGINT
TimeoutStopSec=20
SyslogIdentifier=kapowarr

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now kapowarr
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf V1.0.0-beta-4.zip
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"