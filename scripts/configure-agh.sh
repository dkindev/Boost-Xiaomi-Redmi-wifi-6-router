#!/bin/sh

# Download AdGuard Home
curl --insecure -L https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_linux_armv7.tar.gz | tar xzf - -C /etc

# Create link to /usr/bin
ln -s /etc/AdGuardHome/AdGuardHome /usr/bin/adguardhome

# Create service to run at boot
cat > /etc/init.d/adguardhome << 'EOF'
#!/bin/sh /etc/rc.common

# Service metadata
USE_PROCD=1          # Use modern procd init system
START=99             # Start order (lower = earlier, 95-99 for user services)
STOP=10              # Stop order (higher = later)
SERVICE_WRITE_PID=1  # Let procd manage PID file

WORKING_DIR=/etc/AdGuardHome
COMMAND=/usr/bin/adguardhome

start_service() {
    procd_open_instance
    procd_set_param command $COMMAND -w $WORKING_DIR
    procd_set_param respawn
    procd_close_instance
}
EOF

# Enable execution
chmod +x /etc/init.d/adguardhome

# Enable service to start at boot
/etc/init.d/adguardhome enable

# Start the service now
/etc/init.d/adguardhome start

# Get the IPv4 and IPv6 Address of router and store them in following variables for use during the script.
NET_ADDR=$(ip -o -4 addr list br-lan | awk 'NR==1{ split($4, ip_addr, "/"); print ip_addr[1]; exit }')
NET_ADDR6=$(ip -o -6 addr list br-lan scope global | awk '$4 ~ /^fd|^fc/ { split($4, ip_addr, "/"); print ip_addr[1]; exit }')
 
# 1. Move dnsmasq to port 54.
# 2. Set local domain to "lan".
# 3. Add local '/lan/' to make sure all queries *.lan are resolved in dnsmasq;
# 4. Add expandhosts '1' to make sure non-expanded hosts are expanded to ".lan";
# 5. Disable dnsmasq cache size as it will only provide PTR/rDNS info, making sure queries are always up to date (even if a device internal IP change after a DHCP lease renew).
# 6. Disable reading /tmp/resolv.conf.d/resolv.conf.auto file (which are your ISP nameservers by default), you don't want to leak any queries to your ISP.
# 7. Delete all forwarding servers from dnsmasq config.
uci set dhcp.@dnsmasq[0].port="54"
uci set dhcp.@dnsmasq[0].domain="lan"
uci set dhcp.@dnsmasq[0].local="/lan/"
uci set dhcp.@dnsmasq[0].expandhosts="1"
uci set dhcp.@dnsmasq[0].cachesize="0"
uci set dhcp.@dnsmasq[0].noresolv="1"
uci -q del dhcp.@dnsmasq[0].server
 
# Delete existing config ready to install new options.
uci -q del dhcp.lan.dhcp_option
uci -q del dhcp.lan.dns
 
# DHCP option 3: Specifies the gateway the DHCP server should send to DHCP clients.
uci add_list dhcp.lan.dhcp_option='3,'"${NET_ADDR}"
 
# DHCP option 6: Specifies the DNS server the DHCP server should send to DHCP clients.
uci add_list dhcp.lan.dhcp_option='6,'"${NET_ADDR}" 
 
# DHCP option 15: Specifies the domain suffix the DHCP server should send to DHCP clients.
uci add_list dhcp.lan.dhcp_option='15,'"lan"
 
# Set IPv6 Announced DNS
uci add_list dhcp.lan.dns="$NET_ADDR6"
 
uci commit dhcp
/etc/init.d/dnsmasq restart
/etc/init.d/odhcpd restart