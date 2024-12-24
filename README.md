# Nomad

**Nomad** is a streamlined VPN setup automation tool designed to establish secure and efficient connections between internal and external networks. It supports two tunneling methods: **tinyfecVPN** and **EasyTier**.  

### Key Features:
- **Server Setup:** Automates the configuration of two servers—one in the internal network and one in the external network.
- **OS Hardening:** Implements essential security practices to harden the operating system.
- **SSH Hardening:** Enhances SSH configuration for increased security.
- **Firewall Configuration:** Configures firewall rules to protect servers and secure network traffic.
- **3x-UI Panel Installation:** Installs and sets up the 3x-UI panel for simplified VPN management.
- **Tunnel Configuration:** Configures a VPN tunnel using one of the supported methods for optimized performance.

### Requirements:
- **Two Servers:** One server must be located in the internal network and the other in the external network.  
Nomad simplifies complex configurations, making it an ideal tool for secure and efficient VPN setups.

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
<your-favorite-editor> inventory/group_vars/all/preparing.yml
<your-favorite-editor> inventory/group_vars/all/fec.yml
<your-favorite-editor> inventory/group_vars/all/easytier.yml
<your-favorite-editor> inventory/group_vars/all/xui.yml
```
#### 4. Run `nomad.sh` to install and configure both servers
```bash
chmod +x nomad.sh
```
```bash
./nomad.sh
```
## Verify Installation
1. Check tun interfaces
```bash
ip addr
```
```bash
# Excepted result:
3: nomad-fec: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none 
    inet 10.22.22.1 peer 10.22.22.2/32 scope global nomad-fec
       valid_lft forever preferred_lft forever
    inet6 fe80::906c:9f4e:59f:1522/64 scope link stable-privacy 
       valid_lft forever preferred_lft forever
4: nomad-easytier: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1380 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none 
    inet 10.44.44.1/24 scope global nomad-easytier
       valid_lft forever preferred_lft forever
```
2. Check Services Status
```bash
systemctl status nomad-fec # (if enabled)

systemctl status nomad-easytier # (if enabled)
```
3. Check **FEC** tunnel ping from internal network (if enabled)
```bash
ping 10.22.22.2
```
4. Check **EasyTier** tunnel ping from internal network (if enabled)
```bash
ping 10.44.44.2
```
5. Open **3x-UI** panel in your browser and add your inbounds
```bash
# Replace $YOUR_PUBLIC_IP with your servers public IP and $XUI_PORT with port you set in ``inventory/group_vars/all/xui.yml``
http://$YOUR_PUBLIC_IP:$XUI_PORT
# Example
http://192.168.1.100:2053
```
# Credits
- [tinyfecVPN](https://github.com/wangyu-/tinyfecVPN)
- [EasyTier](https://github.com/EasyTier/EasyTier)
