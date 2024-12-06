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

apt update && apt install -y curl wget htop vim

if ! command -v x-ui &> /dev/null; then
    yes n | bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
fi

/usr/local/x-ui/x-ui setting -port $XUI_PORT -username $XUI_USERNAME -password $XUI_PASSWORD -webBasePath / && /usr/local/x-ui/x-ui migrate

systemctl restart x-ui
