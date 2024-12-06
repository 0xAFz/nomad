# nomad
Gaming VPN Setup Automation

## Usage
Clone repo on both server and client
```bash
git clone https://github.com/0xAFz/nomad.git

cd nomad/
```
At first on both server and client you must edit `.env` file and replace your values 
```bash
cp .env.example .env

vim .env
```
1. #### Server setup
    Run `server.sh` to install and configure server
    ```bash
    chmod +x server.sh

    ./server.sh
    ```
2. #### Client setup
    Run `server.sh` to install and configure client
    ```bash
    chmod +x client.sh

    ./client.sh
    ```
### Panel setup
On both server and client you must install `3x-ui` panel for tunneling and creating vpn inbounds like (wireguard, ..)
```bash
chmod +x panel.sh

./panel.sh
```
Now you should access to panel from this address: http://<YOUR_IP>:<XUI_PORT>/  
example: http://192.168.1.100:2053/

# Credits
- [tinyfecVPN](https://github.com/wangyu-/tinyfecVPN)
