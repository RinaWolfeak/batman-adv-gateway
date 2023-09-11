FROM debian:bullseye
RUN apt update -y && apt install -y batctl net-tools wireless-tools dnsmasq iptables
CMD ["bash", "/start-batman-adv.sh"]
RUN echo 'batman-adv' | tee --append /etc/modules
RUN echo 'denyinterfaces wlan0' | tee --append /etc/dhcpcd.conf
RUN echo 'interface=bat0' | tee --append /etc/dnsmasq.conf
RUN echo 'dhcp-range=192.168.199.2,192.168.199.99,255.255.255.0,12h' | tee --append /etc/dnsmasq.conf
ADD wlan0 /etc/network/interfaces.d/wlan0
ADD start-batman-adv.sh /start-batman-adv.sh
