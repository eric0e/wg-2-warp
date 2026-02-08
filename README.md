# wg-2-warp

**Route WireGuard VPN traffic through Cloudflare WARP for a clean IP address**

## Overview

wg-2-warp combines a WireGuard VPN server with Cloudflare WARP to give your VPN traffic a Cloudflare WARP IP address instead of a standard datacenter IP. This helps avoid the blocks and restrictions that many websites place on VPN traffic from datacenter IPs.

**How it works:**

- Run a WireGuard server on your VPS
- Route all WireGuard client traffic through Cloudflare WARP
- Client traffic exits with a WARP IP address (typically 104.x.x.x range)
- WARP IPs are geographically close to your VPS location
- Fail-secure design prevents traffic from bypassing WARP

**Use cases:**

- Remote access with a "clean" IP address
- Accessing streaming services while traveling
- Bypassing VPN/datacenter IP blocks
- Digital nomads needing reliable connectivity

## Architecture

This project uses two Docker containers connected via a private network:

```
[WireGuard Clients] 
        ↓ (UDP 51822)
[WireGuard Container] → [Private Network] → [WARP Container] → Internet (WARP IP)
```

**Key features:**

- **Two-container design:** WireGuard and WARP in separate containers
- **Policy-based routing:** Uses Linux routing tables to direct traffic through WARP
- **Fail-secure:** Blocks direct internet access if WARP is down
- **TCPMSS clamping:** Prevents MTU issues and connection hangs
- **Persistent storage:** WARP registration persists across restarts

## Prerequisites

**System requirements:**

- x86_64 Linux system (tested on Ubuntu 22.04 and 24.04)
- Docker and Docker Compose installed
- Root or sudo access
- Free UDP port 51822 for WireGuard

**Network requirements:**

- If using a firewall, open UDP port 51822

- For Docker hosts, you may need to add an iptables rule:
  
  ```bash
  sudo iptables -I DOCKER-USER -p udp -m udp --dport 51822 -j ACCEPT
  ```

**Important:** This setup uses wg1 on port 51822. If you are already running another WireGuard server on wg0/port 51820, this configuration will not conflict with it.

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/eric0e/wg-2-warp.git
cd wg-2-warp
```

### 2. Configure WireGuard

Create your WireGuard configuration file:

```bash
cp wireguard/wg1.conf.example wireguard/wg1.conf
```

Edit `wireguard/wg1.conf` with your server and peer details:

```ini
[Interface]
Address = 10.13.13.1/24
SaveConfig = false
ListenPort = 51822
PrivateKey = YOUR_SERVER_PRIVATE_KEY

[Peer]
PublicKey = YOUR_CLIENT_PUBLIC_KEY
AllowedIPs = 10.13.13.2/32
PersistentKeepalive = 0
```

**Generate keys if needed:**

```bash
wg genkey | tee server_private.key | wg pubkey > server_public.key
wg genkey | tee client_private.key | wg pubkey > client_public.key
```

### 3. Build the Docker images

```bash
docker compose build --no-cache
```

### 4. Start the containers

```bash
docker compose up -d
```

### 5. Verify operation

Check that both containers are running:

```bash
docker compose ps
```

View the logs:

```bash
docker compose logs
```

You should see:

- WARP container connecting successfully
- WireGuard container routing through WARP
- External IP showing as 104.x.x.x (WARP address)

## Client Configuration

Configure your WireGuard client to connect to your VPS:

```ini
[Interface]
PrivateKey = YOUR_CLIENT_PRIVATE_KEY
Address = 10.13.13.2/32
DNS = 1.1.1.1
MTU = 1280  # Conservative setting to avoid fragmentation issues

[Peer]
PublicKey = YOUR_SERVER_PUBLIC_KEY
Endpoint = YOUR_VPS_IP:51822
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

Replace:

- `YOUR_CLIENT_PRIVATE_KEY` with your client's private key
- `YOUR_SERVER_PUBLIC_KEY` with your server's public key  
- `YOUR_VPS_IP` with your VPS IP address

## Testing

After connecting your WireGuard client, verify the setup:

**Check your IP address:**

```bash
curl https://icanhazip.com
```

You should see an IP in the 104.x.x.x range (Cloudflare WARP).

**Check detailed connection info:**

```bash
curl https://cloudflare.com/cdn-cgi/trace
```

Look for `warp=on` in the output.

## Management

### Common Docker commands

```bash
# View container status
docker compose ps

# View logs
docker compose logs 

# View logs for specific container
docker compose logs warp
docker compose logs wireguard

# Restart containers
docker compose restart

# Stop containers
docker compose down

# Rebuild after changes
docker compose build --no-cache
docker compose up -d

# Execute commands inside containers
docker exec -it warp-server bash
docker exec -it wireguard-server bash
```

### Inside the containers

**Check WireGuard status:**

```bash
docker exec wireguard-server wg show
```

**Check WARP status:**

```bash
docker exec warp-server warp-cli --accept-tos status
```

**Check routing configuration:**

```bash
docker exec wireguard-server ip route show table 200
docker exec wireguard-server ip rule show
```

**Check firewall rules:**

```bash
docker exec wireguard-server iptables -L FORWARD -n -v
```

## Configuration Options

### Network Subnet

The default private network uses `172.22.0.0/16`. To change:

Edit `docker-compose.yml`:

```yaml
networks:
  warp-net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.25.0.0/16  # Your custom subnet
```

Update IP addresses in:

- `docker-compose.yml` (both services)
- `entrypoint-wireguard.sh` (routing rules)

### WireGuard Network

The default WireGuard network is `10.13.13.0/24`. To change:

Edit `wireguard/wg1.conf` and update routing rules in `entrypoint-wireguard.sh`:

```bash
ip rule add from YOUR_NETWORK/24 table 200 priority 100
iptables -t nat -A POSTROUTING -s YOUR_NETWORK/24 -j MASQUERADE
```

### Adding More Peers

Add additional peer blocks to `wireguard/wg1.conf`:

```ini
[Peer]
PublicKey = ANOTHER_CLIENT_PUBLIC_KEY
AllowedIPs = 10.13.13.3/32
PersistentKeepalive = 0
```

Restart the WireGuard container:

```bash
docker compose restart wireguard
```

## Troubleshooting

### Container fails to start

**Check logs:**

```bash
docker compose logs warp
docker compose logs wireguard
```

**Common issues:**

- WARP fails to register: Delete `warp-data/` directory and restart
- Port already in use: Change port mapping in `docker-compose.yml`
- Permission denied: Ensure Docker has proper privileges

### WARP shows "warp=off"

```bash
docker exec warp-server warp-cli --accept-tos status
docker exec warp-server warp-cli --accept-tos connect
```

If connection fails, delete registration and restart:

```bash
docker compose down
rm -rf warp-data/
docker compose up -d
```

### Client cannot connect

**Verify firewall:**

```bash
sudo iptables -L DOCKER-USER -n -v
```

**Add rule if missing:**

```bash
sudo iptables -I DOCKER-USER -p udp -m udp --dport 51822 -j ACCEPT
```

**Check WireGuard is listening:**

```bash
docker exec wireguard-server wg show
```

### Traffic not routing through WARP

**Verify routing table:**

```bash
docker exec wireguard-server ip route show table 200
```

Should show: `default via 172.22.0.10`

**Verify policy routing:**

```bash
docker exec wireguard-server ip rule show
```

Should show: `from 10.13.13.0/24 lookup 200`

**Test WARP connectivity from WireGuard container:**

```bash
docker exec wireguard-server ping -c 3 172.22.0.10
```

### Connection hangs or slow

The TCPMSS clamping rules should prevent this, but if issues persist:

**Check MTU settings:**

```bash
docker exec warp-server ip link show CloudflareWARP
docker exec wireguard-server ip link show wg1
```

## How It Works

### Routing Flow

1. Client connects to WireGuard server (10.13.13.1) on port 51822
2. WireGuard container receives traffic on wg1 interface
3. Policy routing rule matches source 10.13.13.0/24
4. Traffic is sent to routing table 200
5. Table 200 routes via 172.22.0.10 (WARP container)
6. WARP container NATs traffic through CloudflareWARP interface
7. Traffic exits with WARP IP address (104.x.x.x)

### Security Features

**Fail-secure design:**

```bash
iptables -A FORWARD -i wg1 -o eth0 -j DROP
```

This rule blocks WireGuard traffic from directly accessing eth0 (the internet). Traffic MUST go through the WARP container (172.22.0.10) or it is dropped.

**Health checks:**
Both containers have health checks that verify:

- WARP: Connected to Cloudflare and responding with 104.x.x.x IP
- WireGuard: Interface up, WARP reachable, routing table configured

## Limitations

**Platform support:**

- Tested only on x86_64 Linux
- Ubuntu 22.04 and 24.04 confirmed working
- Other distributions may work but are untested

**Network restrictions:**

- May not work on some VPS providers with restricted networking
- Some providers block or throttle WARP traffic

**Performance:**

- Additional latency from double-encapsulation (WireGuard + WARP)
- WARP free tier may have bandwidth limitations

## Related Projects

This project was inspired by [warp-docker](https://github.com/cmj2002/warp-docker) by cmj2002. While wg-2-warp implements a different architecture specifically for routing WireGuard traffic through WARP, the initial concept came from exploring that project.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

**Areas where contributions would be helpful:**

- Testing on different Linux distributions
- Testing on different VPS providers
- ARM64/ARM support
- IPv6 support improvements
- Documentation improvements

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

- Cloudflare for providing the WARP client and service
- WireGuard for the excellent VPN protocol
- [cmj2002/warp-docker](https://github.com/cmj2002/warp-docker) for inspiration

## Support

For issues and questions:

1. Check the [Troubleshooting](#troubleshooting) section
2. Search existing [GitHub Issues](https://github.com/eric0e/wg-2-warp/issues)
3. Open a new issue with:
   - Your OS and Docker version
   - Complete error logs
   - Steps to reproduce

**Note:** This is a community project. Response times may vary.
