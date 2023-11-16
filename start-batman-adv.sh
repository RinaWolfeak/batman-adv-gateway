#!/bin/bash
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
if [ ! -f /etc/network/interfaces.d/bat0 ]
then
  cp /source/bat0 /etc/network/interfaces.d/
fi
if [ ! -f /etc/network/interfaces.d/wlan0 ]
then
 cp /source/wlan0 /etc/network/interfaces.d/
fi

# Tell batman-adv which interface to use
batctl if add wlan0
ifconfig bat0 mtu 1468


# Tell batman-adv this is an internet gateway
batctl gw_mode server

# Enable port forwarding
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o bat0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i bat0 -o eth0 -j ACCEPT
# Activates the interfaces for batman-adv
ifconfig wlan0 up
ifconfig bat0 up # bat0 is created via the first command
ifconfig bat0 192.168.199.1/24
sleep infinity
