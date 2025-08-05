#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- WireGuard Server Setup Script ---"

# 1. Update and Install Dependencies
echo "[+] Updating package lists and installing WireGuard + iptables..."
sudo apt-get update
sudo apt-get install -y wireguard iptables

# 2. Generate Keys
echo "[+] Generating server keys..."
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey
SERVER_PRIVATE_KEY=$(sudo cat /etc/wireguard/privatekey)
SERVER_PUBLIC_KEY=$(sudo cat /etc/wireguard/publickey)

# 3. Get Network Interface Name
INTERFACE_NAME=$(ip -o -4 route show to default | awk '{print $5}')
echo "[i] Detected primary network interface as: $INTERFACE_NAME"

# 4. Create Server Configuration
echo "[+] Creating server configuration at /etc/wireguard/wg0.conf..."
sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOL
[Interface]
Address = 10.10.0.1/24
SaveConfig = true
ListenPort = 51820
PrivateKey = $SERVER_PRIVATE_KEY
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $INTERFACE_NAME -j MASQUERADE; iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $INTERFACE_NAME -j MASQUERADE; iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Add your client(s) here as [Peer] sections
# [Peer]
# PublicKey = <PASTE_CLIENT_PUBLIC_KEY_HERE>
# AllowedIPs = 10.10.0.2/32
EOL

# 5. Enable IP Forwarding
echo "[+] Enabling IP forwarding..."
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

# 6. Start and Enable WireGuard Service
echo "[+] Starting and enabling WireGuard service..."
sudo systemctl enable --now wg-quick@wg0

# 7. Final Instructions
echo "---"
echo "✅ WireGuard server installation is complete!"
echo ""
echo "Your Server's Public Key is: $SERVER_PUBLIC_KEY"
echo ""
echo "Next steps:"
echo "1. Add a [Peer] section to /etc/wireguard/wg0.conf for each client device."
echo "2. Restart the service after adding a peer: sudo systemctl restart wg-quick@wg0"
echo "3. Configure your client device."