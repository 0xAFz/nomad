#!/bin/bash

DB_PATH="/etc/x-ui/x-ui.db"

ID=201
PORT=8088
REMARK="Nomad"
UUID="d1ac366f-511e-4988-bfad-ce5a49114c33"
EMAIL="external-network"
SUB_ID="l32igb03o0uwtwdc"
DEST="10.44.44.1"

SQL_COMMAND=$(cat <<EOF
INSERT INTO inbounds (id, user_id, up, down, total, remark, enable, expiry_time, listen, port, protocol, settings, stream_settings, tag, sniffing)
VALUES (
    $ID, 1, 0, 0, 0, '$REMARK', 1, 0, '', $PORT, 'vless',
    '{
      "clients": [
        {
          "id": "$UUID",
          "flow": "",
          "email": "$EMAIL",
          "limitIp": 0,
          "totalGB": 0,
          "expiryTime": 0,
          "enable": true,
          "tgId": "",
          "subId": "$SUB_ID",
          "reset": 0
        }
      ],
      "decryption": "none",
      "fallbacks": []
    }',
    '{
      "network": "tcp",
      "security": "none",
      "externalProxy": [
        {
          "forceTls": "same",
          "dest": "$DEST",
          "port": $PORT,
          "remark": ""
        }
      ],
      "tcpSettings": {
        "acceptProxyProtocol": false,
        "header": {
          "type": "http",
          "request": {
            "version": "1.1",
            "method": "GET",
            "path": [
              "/"
            ],
            "headers": {
              "Host": [
                "fast.com"
              ]
            }
          },
          "response": {
            "version": "1.1",
            "status": "200",
            "reason": "OK",
            "headers": {}
          }
        }
      }
    }',
    'inbound-$PORT',
    '{
      "enabled": false,
      "destOverride": [
        "http",
        "tls",
        "quic",
        "fakedns"
      ],
      "metadataOnly": false,
      "routeOnly": false
    }'
);
EOF
)

sqlite3 "$DB_PATH" "$SQL_COMMAND"

if [ $? -eq 0 ]; then
    echo "Inbound inserted successfully."
else
    echo "Failed to insert inbound."
fi
