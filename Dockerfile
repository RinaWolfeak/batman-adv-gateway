FROM ubuntu:22.04
RUN apt update -y && apt install -y batctl net-tools wireless-tools dnsmasq iptables
ADD wlan0 /source/wlan0
ADD start-batman-adv.sh /start-batman-adv.sh
CMD ["bash", "/start-batman-adv.sh"]
