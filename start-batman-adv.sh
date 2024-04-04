#!/bin/bash
nsenter -t 1 -m -u -i -n apt update -y 
nsenter -t 1 -m -u -i -n apt install -y batctl dnsmasq
if ! grep -R "batman-adv" /etc/modules
then
  echo 'batman-adv' | tee --append /etc/modules
fi
if ! grep -R "denyinterfaces wlan0" /etc/dhcpcd.conf
then
  echo 'denyinterfaces wlan0' | tee --append /etc/dhcpcd.conf
fi
if ! grep -R "interface=bat0" /etc/dnsmasq.conf
then
  echo 'interface=bat0' | tee --append /etc/dnsmasq.conf
fi
if ! grep -R "dhcp-range=192.168.199.2,192.168.199.99,255.255.255.0,12h" /etc/dnsmasq.conf
then
  echo 'dhcp-range=192.168.199.2,192.168.199.99,255.255.255.0,12h' | tee --append /etc/dnsmasq.conf
fi
if ! grep -R "wireless-essid" /source/wlan0
then
echo "    wireless-essid $MESH_NAME" | tee --append /source/wlan0
fi
if [ ! -f /etc/network/interfaces.d/wlan0 ]
then
 cp /source/wlan0 /etc/network/interfaces.d/
fi

# Tell batman-adv which interface to use
batctl if add wlan0
ifconfig bat0 mtu 1468


# Tell batman-adv this is an internet gateway
nsenter -t 1 -m -u -i -n batctl gw_mode server

# Enable port forwarding
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o bat0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i bat0 -o eth0 -j ACCEPT
# Activates the interfaces for batman-adv
ifconfig wlan0 up
ifconfig bat0 up
ifconfig bat0 $BAT_IP
service dnsmasq restart
service dhcpcd restart
service networking restart
ifdown wlan0
ifup wlan0
sleep infinity
