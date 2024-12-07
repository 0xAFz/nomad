#!/bin/bash

set -eu

cd $(dirname "$0") || exit 1

if [[ ! -f .env ]]; then
    echo ".env file not found!"
    exit 1
fi

set -o allexport
source .env
set +o allexport

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
else
    source .venv/bin/activate
fi

ansible-playbook -i inventory/hosts.yml vpn.yml
