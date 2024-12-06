#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
else
    echo ".env file not found!"
    exit 1
fi

FILE="$(pwd)/bin/nomad_amd64"

chmod +x $FILE

CONFIG_DIR='/root/nomad'
SERVICE_FILE='/etc/systemd/system/nomad.service'

COMMAND="-c -r$SERVER_ADDR:$PORT $FEC --sub-net $SUBNET --tun-dev nomad --keep-reconnect --disable-obscure"

cat <<EOF >"$SERVICE_FILE"
[Unit]
Description=Nomad Client
After=network.target

[Service]
Type=simple
ExecStart=$CONFIG_DIR/bin/nomad_amd64 $COMMAND
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload &>/dev/null
systemctl enable nomad &>/dev/null
systemctl start nomad &>/dev/null
