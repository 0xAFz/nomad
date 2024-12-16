# nomad
Gaming VPN Setup Automation

## Usage
#### 1. Clone repository on your local machine
```bash
git clone https://github.com/0xAFz/nomad.git

cd nomad/
```
#### 2. At first you must edit `.env` file and replace your values 
```bash
cp .env.example .env

<your-favorite-editor> .env
```
#### 3. Build your own inventory
```bash
cp inventory/sample.yml inventory/hosts.yml
<your-favorite-editor> inventory/hosts.yml

# Review and change parameters under ``inventory/group_vars``
<your-favorite-editor> inventory/group_vars/all/all.yml
```
#### 4. Run `nomad.sh` to install and configure both servers
```bash
chmod +x nomad.sh
```
```bash
./nomad.sh
```
You should access to panel from this address: http://<YOUR_IP>:<XUI_PORT>/  
Example: http://192.168.1.100:2053/

# Credits
- [tinyfecVPN](https://github.com/wangyu-/tinyfecVPN)
- [EasyTier](https://github.com/EasyTier/EasyTier)
