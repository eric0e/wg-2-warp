#!/bin/bash  

echo "Starting dbus..."
mkdir -p /run/dbus
dbus-daemon --system --fork &>/dev/null
sleep 2

echo "Starting Cloudflare WARP service..."
warp-svc --accept-tos &>/dev/null &
sleep 4

# if registration is missing, try to created it
echo "Checking registration status..."
REG_FILE="/var/lib/cloudflare-warp/reg.json"
for i in {1..5}; do
    if [[ -f "$REG_FILE" && -s "$REG_FILE" ]]; then
        # echo "File '$REG_FILE' is a non-empty regular file."
        echo "Registration found at: $REG_FILE"
	break
    else  
        echo "No registration found, creating new registration..."
        warp-cli --accept-tos registration new
        echo "Waiting... ($i/5)"
	sleep 5 # Takes time after registration be ready
    fi
done

# abort if registration file not created
if [[ ! -f "$REG_FILE" || ! -s "$REG_FILE" ]]; then
    echo "Registration failed, aborting"
    exit 2
fi

echo "Checking if warp-svc is ready..."
for i in {1..10}; do
    if warp-cli --accept-tos status &>/dev/null; then
        echo "warp-svc is ready"
        break
    fi
    echo "Waiting... ($i/10)"
    sleep 5 
done

echo "Connecting..."
warp-cli  --accept-tos connect
sleep 2
for i in {1..10}; do
    warp-cli --accept-tos status | grep -q Connected
    if [ $? -eq 0 ] ; then
       echo "Connected"
       break
    fi
    echo "Waiting... ($i/10)"
    warp-cli  --accept-tos connect
    sleep 5
done

sleep 2 
# Verify Connected
warp-cli --accept-tos status | grep -q Connected
if [ $? -eq 0 ] ; then
    echo "Connected - Reconfirmed"
else
    echo "Connecton failed, aborting"
    exit 2
fi

echo ""
echo "=== WARP Status ==="
warp-cli --accept-tos status
echo ""

# Allow forwarding from other containers
echo "iptables -A FORWARD -i eth0 -j ACCEPT"
echo "iptables -A FORWARD -o eth0 -j ACCEPT"
iptables -A FORWARD -i eth0 -j ACCEPT
iptables -A FORWARD -o eth0 -j ACCEPT

# NAT traffic from other containers through WARP
WARP_IFACE=$(ip link show | grep -i cloudflare | head -1 | awk -F': ' '{print $2}' | cut -d'@' -f1)
if [ -n "$WARP_IFACE" ]; then
    echo "Found WARP interface: $WARP_IFACE"
    echo "iptables -t nat -A POSTROUTING -o "$WARP_IFACE" -j MASQUERADE"
    iptables -t nat -A POSTROUTING -o "$WARP_IFACE" -j MASQUERADE
    echo "Setting TCPMSS clamp-mss-to-pmtu on $WARP_IFACE"
    iptables -t mangle -A FORWARD -o $WARP_IFACE -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
    iptables -t mangle -A FORWARD -i $WARP_IFACE -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
else
    echo "WARP interface $WARP_IFACE not found, aborting"
    exit 2
fi

echo ""
echo "=== Testing WARP Connection ==="
EXTERNAL_IP=$(curl -4 -s --max-time 10 ifconfig.me 2>/dev/null)
if [ -n "$EXTERNAL_IP" ]; then
    echo "External IP: $EXTERNAL_IP"
    ORG=$(curl -4 -s --max-time 10 "https://ipinfo.io/$EXTERNAL_IP/org" 2>/dev/null)
    echo "Organization: $ORG"
else
    echo "Could not retrieve external IP"
fi

echo ""
echo "WARP container is ready and will act as gateway for WireGuard container"

tail -f /dev/null

