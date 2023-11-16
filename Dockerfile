FROM ubuntu
RUN apt update -y && apt install -y batctl net-tools wireless-tools dnsmasq iptables
ADD bat0 /source/bat0
ADD wlan0 /source/wlan0
ADD start-batman-adv.sh /start-batman-adv.sh
CMD ["bash", "/start-batman-adv.sh"]
