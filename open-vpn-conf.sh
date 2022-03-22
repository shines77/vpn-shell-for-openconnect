#!/bin/bash

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
# anyconnect	   Compatible with Cisco AnyConnect	SSL	VPN, as	well as	ocserv (default)
# nc			   Compatible with Juniper Network Connect
# gp			   Compatible with Palo	Alto Networks (PAN)	GlobalProtect SSL VPN
# pulse			   Compatible with Pulse Connect Secure	SSL	VPN
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
# anyconnect	   Compatible with Cisco AnyConnect	SSL	VPN, as	well as	ocserv (default)
# nc			   Compatible with Juniper Network Connect
# gp			   Compatible with Palo	Alto Networks (PAN)	GlobalProtect SSL VPN
# pulse			   Compatible with Pulse Connect Secure	SSL	VPN
export VPN2_PROTOCOL="<vpn.protocol>"
# SHA1
export VPN2_SERVER_CERTIFICATE=""
