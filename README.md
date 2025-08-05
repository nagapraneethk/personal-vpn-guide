# Personal WireGuard® VPN Setup Guide

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive, step-by-step guide to creating your own secure, private, and extremely low-cost VPN using WireGuard on a free-tier cloud server.

### Introduction
In an age of dwindling digital privacy, taking control of your internet connection is more important than ever. Commercial VPNs are a good option, but they require trusting a third party with your data. This guide walks you through the entire process of building your own VPN server, giving you ultimate control and privacy. This project was born from a real-world need to bypass a highly restrictive network and documents the entire successful setup and troubleshooting process.

### Features
- ✅ **Secure & Modern:** Uses the fast, lean, and highly-regarded WireGuard® protocol.
- ✅ **Extremely Low-Cost:** Designed to run on "Always Free" or 12-month "Free Tier" accounts from Google Cloud, AWS, and Oracle Cloud.
- ✅ **Full Control:** You own the server and the data. No third-party logging.
- ✅ **Comprehensive:** Includes setup, client configuration, and a battle-tested troubleshooting guide.
- ✅ **(Optional) Network-Wide Ad Blocking:** Can be combined with Pi-hole for blocking ads on all your connected devices.

### Prerequisites
- A Google Cloud (GCP), AWS, or Oracle Cloud account with a valid payment method for verification (you will not be charged if you stay within the free tier).
- Basic comfort with using a command-line terminal.
- A client device (macOS, Windows, Linux, iOS, or Android).

---

### Part 1: Server Setup (GCP Example)
1.  Navigate to `Compute Engine > VM Instances` in your GCP Console.
2.  Click **"Create Instance"**.
3.  Configure as follows:
    - **Name:** `vpn-server`
    - **Region:** A location close to you.
    - **Machine Type:** `e2-micro` (this is part of the Always Free tier in certain US regions).
    - **Boot Disk:** Change to **Ubuntu 22.04 LTS**.
4.  Create the instance.

### Part 2: Firewall Configuration
1.  Navigate to `VPC Network > Firewall` and create a new rule.
2.  **Name:** `allow-wireguard`
3.  **Targets:** Apply to a specific network tag, e.g., `vpn-server`.
4.  **Source IPv4 ranges:** `0.0.0.0/0`
5.  **Protocols and ports:** Check `UDP` and enter `51820`.
6.  Save the rule and apply the `vpn-server` network tag to your VM instance.

### Part 3: Server Installation & Configuration
1.  SSH into your newly created server.
2.  You can run the installation script provided in this repository for a quick setup:
    ```bash
    # Download the script
    curl -O [https://raw.githubusercontent.com/nagapraneethk/personal-vpn-guide/main/scripts/install-wireguard.sh](https://raw.githubusercontent.com/nagapraneethk/personal-vpn-guide/main/scripts/install-wireguard.sh)
    # Make it executable
    chmod +x install-wireguard.sh
    # Run the script
    ./install-wireguard.sh
    ```
3.  The script will install WireGuard and guide you through creating the configuration.

### Part 4: Client Configuration
1.  Install the official WireGuard client for your OS.
2.  Use the `client.conf.sample` template from the `config-templates` directory in this repo.
3.  Fill in your client private key, the server's public key, and the server's public IP address.
4.  Import the configuration and connect!

---

### 🏆 Troubleshooting Guide
This is the most important section, based on real-world problems.

* **Problem: "Handshake did not complete..."**
    * **Meaning:** Your client can't reach the server.
    * **Solutions:**
        1.  Double-check that your cloud firewall rule for **UDP port 51820** is correct and applied to the VM.
        2.  Verify the `Endpoint` IP address in your client config matches the server's **External IP** exactly.
        3.  Confirm the server's `PublicKey` in your client config is correct, and vice-versa.

* **Problem: Connects successfully, but no internet access.**
    * **Meaning:** A routing or NAT problem on the server.
    * **Solutions:**
        1.  **Check Network Interface Name:** SSH into the server and run `ip addr`. The main interface is likely `ens4` or `eth0`. Ensure this name is used correctly in the `PostUp` and `PostDown` rules in `/etc/wireguard/wg0.conf`.
        2.  **Verify IP Forwarding:** Run `cat /proc/sys/net/ipv4/ip_forward`. It **must** return `1`.
        3.  **Fix MTU Issues:** If you are on a restrictive network, packet size can be an issue. Edit `/etc/wireguard/wg0.conf` and add `iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu` to your `PostUp`/`PostDown` rules. The full line is in the config template.

### License
This project is licensed under the MIT License. See the `LICENSE` file for details.