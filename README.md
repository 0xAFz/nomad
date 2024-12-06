# nomad
Gaming VPN Setup Automation

## Usage
Clone repo on both servers (client, server)
```bash
git clone https://github.com/0xAFz/nomad.git

cd nomad/
```
At first on both servers (client, server) you must edit `.env` file and replace your values 
```bash
cp .env.example .env

vim .env
```
1. #### Server setup
    Run `nomad.sh server` to install and configure server
    ```bash
    chmod +x nomad.sh

    ./nomad.sh server
    ```
2. #### Client setup
    Run `nomad.sh client` to install and configure client
    ```bash
    chmod +x nomad.sh

    ./nomad.sh client
    ```
### Panel setup
On both servers (client, server) you must install `3x-ui` panel for tunneling and creating VPN inbounds like (wireguard, ..)
```bash
chmod +x panel.sh

./panel.sh
```
Now you should access to panel from this address: http://<YOUR_IP>:<XUI_PORT>/  
Example: http://192.168.1.100:2053/

# Credits
- [tinyfecVPN](https://github.com/wangyu-/tinyfecVPN)
