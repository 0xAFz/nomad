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
- **Tunnel Configuration:** Sets up a VPN tunnel using supported methods to optimize performance.

---

### Supported Methods:
- **Tunneling between 2 servers:**
  - EasyTier
  - SIT (6to4)
  - IP6GRE
- **Xray Core**

Alright, let’s roll and get started with Nomad! 🛠️

---

### SSH Port Configuration  
We recommend changing the default SSH port for better security when setting up your servers.  

To change the SSH port, connect to your server and run the following command:  

```bash
sed -i 's/#Port 22/Port 3122/g' /etc/ssh/sshd_config && systemctl restart sshd
```  

This one-liner will update the SSH configuration to use port `3122` and restart the SSH service to apply the changes.  

> [!NOTE]
> Make sure to update your firewall rules to allow the new SSH port before running this command, so you don't accidentally lock yourself out.  

---

## Firewall Configuration

By default, the firewall blocks all traffic except the ports and IP ranges you specify in `inventory/group_vars/all/preparing.yml`. Wanna open or close a port? Easy, just edit the `firewall_config` section like this:

```yml
# firewall configuration
firewall_config:
  network_adapter_access:
    - lo
  tcp_port_access:
    - 8084
    - 8082
  udp_port_access:
    - 8084
    - 8082
  trusted_range:
    - 10.44.44.0/24
    - "{{ hostvars['external-network'].ansible_host }}/32"
    - "{{ hostvars['internal-network'].ansible_host }}/32"
```

After editing, run the following command to update the firewall rules:

```bash
# if using nftables
ansible-playbook -i inventory/hosts.yml vpn.yml --tags nftables

# if using iptables
ansible-playbook -i inventory/hosts.yml vpn.yml --tags iptables
```

---

## Tunneling

### EasyTier

**Heads up!** Tunneling needs two servers—one in the internal network and one in the external network. Let’s set up EasyTier with the reverse tunneling method, which we recommend.

#### Step 1: Create the Inventory File

Tell Ansible where to work by creating the `hosts.yml` file:

```yml
all:
  hosts:
    internal-network:
      ansible_host: <your-internal-server-ip>
      ansible_port: 3122
      ansible_user: root
    external-network:
      ansible_host: <your-external-server-ip>
      ansible_port: 3122
      ansible_user: root
```

#### Step 3: Update the Config Files

Edit the following files to match your requirements:

```bash
<your-favorite-editor> inventory/group_vars/all/all.yml
<your-favorite-editor> inventory/group_vars/all/ip6gre.yml
<your-favorite-editor> inventory/group_vars/all/sit.yml
<your-favorite-editor> inventory/group_vars/all/preparing.yml
<your-favorite-editor> inventory/group_vars/all/easytier.yml
<your-favorite-editor> inventory/group_vars/all/xray.yml
<your-favorite-editor> inventory/group_vars/all/xui.yml
```

#### Step 4: Enable EasyTier

Set `enable_easytier` to `true` in `all.yml`:

```yml
## Set to true to enable the EasyTier service
enable_easytier: true
```

By default tunneling method is reversed in `easytier.yml`
```yml
## Tunneling
easytier_reverse: true
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

## Without Tunneling Inventory

If you’re skipping tunneling, use a single server:

```yml
all:
  hosts:
    vpn:
      ansible_host: <server-ip>
      ansible_port: 3122
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

2. Use the default config or replace it with your custom Xray config:

> [!WARNING]
> The name of config files for internal-network must be: `internal.json` for external-network: `external.json`
> For one server only use `default.json`
```bash
cp /path/internal.json roles/xray/files/internal.json
cp /path/external.json roles/xray/files/external.json
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

# Credits

- [EasyTier](https://github.com/EasyTier/EasyTier)
- [Xray](https://github.com/XTLS/Xray-core)
