#!/bin/bash

DB_PATH="/etc/x-ui/x-ui.db"

NEW_CONFIG='{
  "log": {
    "access": "none",
    "dnsLog": false,
    "error": "",
    "loglevel": "warning",
    "maskAddress": ""
  },
  "api": {
    "tag": "api",
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ]
  },
  "inbounds": [
    {
      "tag": "api",
      "listen": "127.0.0.1",
      "port": 62789,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      }
    }
  ],
  "outbounds": [
      {
      "tag": "Nomad",
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "10.44.44.1",
            "port": 8088,
            "users": [
              {
                "id": "d1ac366f-511e-4988-bfad-ce5a49114c33",
                "flow": "",
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "header": {
            "type": "http",
            "request": {
              "headers": {
                "Host": [
                  "fast.com"
                ]
              },
              "path": [
                "/"
              ]
            }
          }
        }
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "AsIs",
        "redirect": "",
        "noises": []
      }
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    }
  ],
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundDownlink": true,
      "statsInboundUplink": true,
      "statsOutboundDownlink": true,
      "statsOutboundUplink": true
    }
  },
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  },
  "stats": {}
}'

sqlite3 $DB_PATH "UPDATE settings SET value = '$NEW_CONFIG' WHERE key = 'xrayTemplateConfig';"

echo "xrayTemplateConfig updated successfully."
