#!/system/bin/sh
iptables -A PREROUTING -t nat -p udp --dport 9 -j REDIRECT --to-port 1025
