#!/bin/bash

set -eu

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

if [[ ! -f .env ]]; then
    echo ".env file not found!"
    exit 1
fi

set -o allexport
source .env
set +o allexport

FILE="$(pwd)/bin/nomad_amd64"
CONFIG_DIR='/root/nomad'
SERVICE_FILE='/etc/systemd/system/nomad.service'

if [[ ! -x "$FILE" ]]; then
    chmod +x "$FILE"
fi

reload_service() {
    systemctl daemon-reload
    systemctl enable nomad
    systemctl restart nomad
}

server_setup() {
    COMMAND="-s -l[::]:$PORT $FEC --sub-net $SUBNET --mode 1 --timeout 1 --tun-dev nomad --disable-obscure"

    cat <<EOF >"$SERVICE_FILE"
[Unit]
Description=Nomad Server
After=network.target

[Service]
Type=simple
ExecStart=$CONFIG_DIR/bin/nomad_amd64 $COMMAND
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    reload_service
}

client_setup() {
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

    reload_service
}

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <server|client>"
    exit 1
fi

case "$1" in
    server)
        server_setup
        ;;
    client)
        client_setup
        ;;
    *)
        echo "Invalid action. Use 'server' or 'client'."
        exit 1
        ;;
esac
