#! /bin/sh
#
# with no arg, flush all. Arg "start" flush & restart

########################## *THE* local config
LAN_NET="10.0.0.0/8"
LAN_IP="10.0.1.207"
LAN_PORT="rausb0"

DSK_NET="192.168.0.0/16"
DSK_IP="192.168.1.1"
DSK_PORT="eth0"
TERA_IP="192.168.1.2"
TERA_PORTS="80,139"

########################## cleaning up
echo "disabling forwarding..."
echo 0 > /proc/sys/net/ipv4/ip_forward
echo "cleaning up chains & tables..."
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

########################## should we start?
[ A${1} != Astart ] && echo iptables stopped && exit 0
echo "starting iptables..."

########################## default policies
echo "setting default policies..."
#iptables -P INPUT DROP
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

########################## chains creation
echo "creating chains..."
iptables -N local
iptables -N log
iptables -N state_check

########################## state check
echo "checking state..."
iptables -A state_check -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A state_check -j DROP

iptables -A INPUT -j state_check
iptables -A OUTPUT -j state_check
iptables -A FORWARD -j state_check

########################## loopback
#echo "accepting loopback..."
#iptables -A local -s 127.0.0.1/8 -d 127.0.0.1/8 -j ACCEPT
#iptables -A local -s 127.0.0.1/8 -d 0.0.0.1/0 -j ACCEPT
#iptables -A local -j DROP
#iptables -A INPUT -s 127.0.0.1/32 -j local
#iptables -A OUTPUT -d 127.0.0.1/32 -j local

########################## nat - TODO
echo "starting NAT..."
iptables -A POSTROUTING -t nat -o ${LAN_PORT} -s ${DSK_NET} -j MASQUERADE
#iptables -t nat -A POSTROUTING -o ${LAN_PORT} -j SNAT --to-source ${LAN_IP}

########################## forward/input my ports
# port 80 139 from LAN to DSK
echo "routing ports ${TERA_PORTS} to TERA..."
for port in 80 139
do
  iptables -t nat -I PREROUTING -p tcp -d ${LAN_IP} --dport ${port} -j DNAT --to-destination ${TERA_IP}
  iptables -A FORWARD -p tcp -i ${LAN_PORT} -d ${TERA_IP} --dport ${port} -j ACCEPT
done

# port 138-138 from DSK
#iptables -t nat -I PREROUTING -p udp -d ${DSK_IP} --dport 135:139 -j DNAT --to-destination ${DSK_IP}
#iptables -I FORWARD -p udp -i ${LAN_PORT} -d ${INT_IP} --dport 135:139 -j ACCEPT

########################## logs
#echo "we are watching you now :-)"
#iptables -A log -j LOG --log-level info --log-prefix "IPTABLES: "
#iptables -A log -j DROP
#iptables -A INPUT -j log
#iptables -A OUTPUT -j log
#iptables -A FORWARD -j log

########################## accept forwarding
echo "enabling forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

