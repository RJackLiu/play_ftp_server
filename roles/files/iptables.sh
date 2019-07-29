#!/bin/bash

iptables -t filter -F

iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -t filter -A INPUT -m state --state INVALID -j DROP

#============================================================================

iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT

iptables -t filter -A INPUT -p icmp -j ACCEPT

#============================================================================

iptables -t filter -A INPUT -j REJECT --reject-with icmp-host-prohibited

iptables -t filter -A FORWARD -j REJECT --reject-with icmp-host-prohibited