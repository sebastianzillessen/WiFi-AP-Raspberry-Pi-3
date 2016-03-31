#!/bin/bash

SSID="${1:-WiFiAPi}"
PASSPHRASE="${2:-Raspberrypi}"
IP_RANGE="${3:-192.168.1}"
INC="${4:-eth0}"
WIFI="${5:-wlan0}"


echo "Setting up your WiFi-Accesspoint on your pi with:"
echo " SSID: $SSID"
echo " PASSPHRASE: $PASSPHRASE"
echo " IP-Address: $IP_RANGE.1"
echo " IP-Range: $IP_RANGE.0"
echo " Incomming device: $INC"
echo " WiFi device: $WIFI"


# update os
apt-get update
#apt-get -y upgrade
apt-get -y install hostapd isc-dhcp-server iptables

# check wlan0 available

if ! ifconfig -a | grep "$WIFI"; then
  echo "$WIFI not found, exiting";
  exit -1
fi
if ! ifconfig -a | grep "$INC"; then
  echo "$INC not found, exiting";
  return -1
fi

# modify dhcp.conf
sed -i.bak 's/option domain-name/\#option domain-name/g' /etc/dhcp/dhcpd.conf
sed -i 's/#authoritative;/authoritative;/g' /etc/dhcp/dhcpd.conf

# add ip addresses
CONF="
subnet $IP_RANGE.0 netmask 255.255.255.0 {
  range $IP_RANGE.10 $IP_RANGE.50;
  option broadcast-address $IP_RANGE.255;
  option routers $IP_RANGE.1;
  default-lease-time 600;
  max-lease-time 7200;
  option domain-name "local";
  option domain-name-servers 8.8.8.8, 8.8.4.4;
}
"
echo "$CONF" >> /etc/dhcp/dhcpd.conf

# set where DHCP runs
sed -i.bak "s/\(INTERFACES *= *\).*/\1\"$WIFI\"/" /etc/default/isc-dhcp-server

# set static ip address for $WIFI
INTERF_CONF="
# interfaces(5) file used by ifup(8) and ifdown(8)
# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface $INC inet manual

allow-hotplug $WIFI
iface $WIFI inet static
  address $IP_RANGE.1
  netmask 255.255.255.0
"
echo "$INTERF_CONF" > /etc/network/interfaces
ifconfig $WLAN $IP_RANGE.1

# setup hostapd.conf
CONF_HOST="interface=$WIFI
ssid=$SSID
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASSPHRASE
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP"
echo "$CONF_HOST" > /etc/hostapd/hostapd.conf
# replace SSID and Passphrase

# deamon config
sed -i.bak 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

# add ip-forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward

# add iptables
iptables -t nat -F
iptables -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i $INC -o $WIFI -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $WIFI -o $INC -j ACCEPT
# save iptables
iptables-save > /etc/iptables.ipv4.nat

# load on boot
echo '#!/bin/sh' > /etc/network/if-up.d/iptables
echo "echo 'RUNNING iptables restore now'" >> /etc/network/if-up.d/iptables
echo "iptables-restore < /etc/iptables.ipv4.nat" >> /etc/network/if-up.d/iptables
echo "exit 0;" >> /etc/network/if-up.d/iptables

chmod +x /etc/network/if-up.d/iptables

# test access point
echo "Installation done!"
/usr/sbin/hostapd /etc/hostapd/hostapd.conf & 
