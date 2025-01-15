# Nomad

Hey there, welcome to the **Nomad Documentation**! 🌟 Nomad is like your best buddy for setting up a secure and low-latency VPN server. But that’s not all—you can also use it in a bunch of other creative ways. Let’s dive in together and see what makes Nomad awesome! 🚀

---

### Key Features:

Here’s a quick list of what Nomad can do for you:

- **Server Setup:** Automates the configuration of two servers—one inside the network (internal) and one outside (external).
- **OS Hardening:** Implements solid security practices to keep your operating system safe and sound.
- **SSH Hardening:** Locks down SSH settings for better security.
- **Firewall Configuration:** Sets up firewall rules to protect servers and secure network traffic.
- **Xray Core:** Installs and configures the Xray core for advanced VPN capabilities.
- **3x-UI Panel Installation:** Makes VPN management a breeze with the 3x-UI panel.
- **Tunnel Configuration:** Sets up a VPN tunnel using supported methods to optimize performance.

---

### Supported Methods:
- **Tunneling between 2 servers:**
  - EasyTier
  - tinyfecVPN
- **Xray Core**
- **3x-UI**

Alright, let’s roll and get started with Nomad! 🛠️

---

### SSH Port Configuration  
We recommend changing the default SSH port for better security when setting up your servers.  

To change the SSH port, connect to your server and run the following command:  

```bash
sed -i 's/#Port 22/Port 3022/g' /etc/ssh/sshd_config && systemctl restart sshd
```  

This one-liner will update the SSH configuration to use port `3022` and restart the SSH service to apply the changes.  

> [!NOTE]
> Make sure to update your firewall rules to allow the new SSH port before running this command, so you don't accidentally lock yourself out.  

---

## Firewall Configuration

By default, the firewall blocks all traffic except the ports and IP ranges you specify in `inventory/group_vars/all/preparing.yml`. Wanna open or close a port? Easy, just edit the `iptables` section like this:

```yml
# iptables configuration
iptables:
  network_adapter_access:
    - lo
  tcp_port_access:
    - 8084
    - 8082
  udp_port_access:
    - 8084
    - 8082
  trusted_range:
    - 10.22.22.0/24
    - 10.44.44.0/24
    - 10.0.0.0/24
    - "{{ hostvars['external-network'].ansible_host }}/32"
    - "{{ hostvars['internal-network'].ansible_host }}/32"
```

After editing, run the following command to update the firewall rules:

```bash
ansible-playbook -i inventory/hosts.yml vpn.yml --tags iptables
```

---

## Tunneling

### EasyTier

**Heads up!** Tunneling needs two servers—one in the internal network and one in the external network. Let’s set up EasyTier with the reverse tunneling method, which we recommend.

#### Step 1: Configure the `.env` File

If you’re using 3x-UI, you’ll need to configure the `.env` file first:

```bash
cp .env.example .env

<your-favorite-editor> .env
```

Set your username and password for 3x-UI. If you’re not using it, skip this step.

#### Step 2: Create the Inventory File

Tell Ansible where to work by creating the `hosts.yml` file:

```yml
all:
  hosts:
    internal-network:
      ansible_host: <external-network>
      ansible_port: 3022
      ansible_user: root
    external-network:
      ansible_host: <internal-network>
      ansible_port: 3022
      ansible_user: root
```

For reverse tunneling, swap the IPs of `internal-network` and `external-network`.

#### Step 3: Update the Config Files

Edit the following files to match your requirements:

```bash
<your-favorite-editor> inventory/group_vars/all/all.yml
<your-favorite-editor> inventory/group_vars/all/preparing.yml
<your-favorite-editor> inventory/group_vars/all/fec.yml
<your-favorite-editor> inventory/group_vars/all/easytier.yml
<your-favorite-editor> inventory/group_vars/all/xui.yml
```

#### Step 4: Enable EasyTier

Set `enable_easytier` to `true` in `all.yml`:

```yml
## Set to true to enable the EasyTier service
enable_easytier: true
```

Then configure EasyTier in `easytier.yml`. For example:

```yml
easytier_multithread: true
```

For optimal performance, keep multithreading enabled (it reduces ping by spreading tasks across multiple threads).

#### Step 5: Set a Network Secret

Generate a new secret using:

```bash
openssl rand -hex 6
```

Replace the default secret with your custom one in `easytier.yml`.

#### Step 6: Run the Playbook

You’re ready! Execute this command:

```bash
ansible-playbook -i inventory/hosts.yml vpn.yml
```

Nomad will handle OS hardening, kernel optimization, and firewall configuration. Errors? No worries, read the error message and rerun the command. 😂

Verify the setup:

```bash
systemctl status easytier
```

```bash
ip addr
```
Expected output:

```bash
3: easytier: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1380 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none 
    inet 10.44.44.1/24 scope global easytier
       valid_lft forever preferred_lft forever
```

---

### TinyFecVPN

> [!WARNING]
> TinyFecVPN is supported only on `x86_64` or `amd64` architectures.

Setup is similar to EasyTier:

1. Edit `all.yml` and set `enable_tinyfec` to `true`:

```yml
enable_tinyfec: true
```

2. Configure options in `tinyfec.yml`:

```yml
fec: "20:10"
```

Run the playbook:

```bash
ansible-playbook -i inventory/hosts.yml vpn.yml
```

Verify:

```bash
systemctl status tinyfec
```

```bash
ip addr
```
Expected output:

```bash
3: tinyfec: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none 
    inet 10.22.22.1 peer 10.22.22.2/32 scope global tinyfec
       valid_lft forever preferred_lft forever
    inet6 fe80::906c:9f4e:59f:1522/64 scope link stable-privacy 
       valid_lft forever preferred_lft forever
```

---

## Without Tunneling Inventory

If you’re skipping tunneling, use a single server:

```yml
all:
  hosts:
    vpn:
      ansible_host: <server-ip>
      ansible_port: 3022
      ansible_user: root
```

---

## Xray Core

> [!WARNING]
> Xray is supported only on x86\_64 or amd64 architectures.&#x20;

For installing Xray Core:

1. Set `enable_xray` to `true` in `all.yml`:

```yml
enable_xray: true
```

2. Use the default config or replace it:

```bash
cp /path/config.json roles/client/files/config.json
cp /path/config.json roles/server/files/config.json
```

Run the playbook:

```bash
ansible-playbook -i inventory/hosts.yml vpn.yml
```

Verify:

```bash
systemctl status xray
```

```bash
ss -tulpn
```

---

## 3x-UI

You’ll need to configure the `.env` file first:

```bash
cp .env.example .env

<your-favorite-editor> .env
```

Enable 3x-UI by setting `enable_xui` to `true` in `all.yml`:

```yml
enable_xui: true
```

Configure options in `xui.yml`. Default settings:

```yml
xui_listen: 127.0.0.1
xui_port: 2053
xui_web_path: /
```

> [!WARNING]
> For the security reasons, we blocked all public traffic to panels

After installation, access the panel by creating an SSH tunnel:

```bash
ssh -L 8080:127.0.0.1:2053 user@ip
```

> [!NOTE]
> To be able to do SSH port forwarding, you must allow tcp forwarding `AllowTcpForwarding yes` in `/etc/ssh/sshd_config`  
> By default we enabled it in the preparing tasks

Then open in your browser:

```bash
http://localhost:8080
```

---

# Credits

- [EasyTier](https://github.com/EasyTier/EasyTier)
- [Xray](https://github.com/XTLS/Xray-core)
- [tinyfecVPN](https://github.com/wangyu-/tinyfecVPN)
- [3x-UI](https://github.com/MHSanaei/3x-ui)
