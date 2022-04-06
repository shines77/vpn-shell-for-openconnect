#!/bin/bash

#
# Author: Sorin-Doru Ipate, Since: 2021-03-18
# Edited by: Mohammad Amin Dadgar
# 
# Last edited by: GuoXiongHui(shines77), Since: 2022-03-22
#
# Copyright	(c) Sorin-Doru Ipate & GuoXiongHui(shines77)
#

#
# From: https://github.com/shines77/vpn-shell-for-openconnect/blob/master/open-vpn-cmd.sh
# From: https://gitee.com/shines77/vpn-shell-for-openconnect/blob/master/open-vpn-cmd.sh
#
# From: https://github.com/sorinipate/vpn-up-for-openconnect/blob/main/vpn-up.command
#

##########################################################################################

#
# VPN server configuration
#

# VPN OPTION 1
export VPN1_NAME="VPN Name1"
export VPN1_HOST="<vpn.server_ip>"
# <optinaol>
export VPN1_AUTHGROUP="<vpn.group>"
export VPN1_USER="<vpn.username>"
export VPN1_PASSWD="<vpn.password>"
# anyconnect       Compatible with Cisco AnyConnect SSL VPN, as well as ocserv (default)
# nc               Compatible with Juniper Network Connect
# gp               Compatible with Palo Alto Networks (PAN) GlobalProtect SSL VPN
# pulse            Compatible with Pulse Connect Secure SSL VPN
export VPN1_PROTOCOL="<vpn.protocol>"
# SHA1
export VPN1_SERVER_CERTIFICATE=""

# VPN OPTION 2
export VPN2_NAME="VPN Name2"
export VPN2_HOST="<vpn.server_ip>"
# <optinaol>
export VPN2_AUTHGROUP="<vpn.group>"
export VPN2_USER="<vpn.username>"
export VPN2_PASSWD="<vpn.password>"
# anyconnect       Compatible with Cisco AnyConnect SSL VPN, as well as ocserv (default)
# nc               Compatible with Juniper Network Connect
# gp               Compatible with Palo Alto Networks (PAN) GlobalProtect SSL VPN
# pulse            Compatible with Pulse Connect Secure SSL VPN
export VPN2_PROTOCOL="<vpn.protocol>"
# SHA1
export VPN2_SERVER_CERTIFICATE=""

##########################################################################################

## 
## Whether use your ip route settings? default value is 1 (enable).
## If you are not connecting to a server through SSH terminal, please set to 0.
## 0: disable, 1: enable
##
use_my_ip_route_settings=1

##
## >>
## >> Your ip route exclude settings, please edit it according to your situation. <<
## >> If you are not connecting to a server through SSH terminal, please ignore it.
## >>
##
function add_ip_route_settings() {
	if [ $use_my_ip_route_settings -eq 1 ]; then
		#
		# Exclude your VPN client computer IP,
		# OpenConnect can help us exclude the VPN server IP, so don't worry about it.
		#
		sudo ip route add 123.45.67.98 via 172.16.0.1 dev eth0
		sudo ip route add 123.45.67.89 via 10.0.20.1 dev eth0

		#
		# Exclude your SSH terminal computer IP, if your computer IP is a Dynamic IP,
		# you can exclude a network range like:
		# 120.0.0.0/8, or 124.0.0.0/8
		#
		sudo ip route add 120.0.0.0/8 via 172.16.0.1 dev eth0
		sudo ip route add 124.0.0.0/8 via 172.16.0.1 dev eth0

		sudo ip route add 120.0.0.0/8 via 10.0.20.1 dev eth0
		sudo ip route add 124.0.0.0/8 via 10.0.20.1 dev eth0
	fi
}

##########################################################################################
