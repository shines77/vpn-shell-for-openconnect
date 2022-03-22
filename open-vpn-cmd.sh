#!/bin/bash

#
# Author: Sorin-Doru Ipate, Since: 2021-03-18
# Edited by: Mohammad Amin Dadgar
# 
# Last edited by: GuoXiongHui(shines77), Since: 2022-03-22
#
# Copyright	(c)	Sorin-Doru Ipate & GuoXiongHui(shines77)
#

#
# From: https://github.com/shines77/vpn-shell-for-openconnect/blob/master/open-vpn-cmd.sh
#
# From:	https://github.com/sorinipate/vpn-up-for-openconnect/blob/main/vpn-up.command
#

PROGRAM_NAME=$(basename	$0)
echo "Starting ${PROGRAM_NAME} ..."

# PID_FILE="${PWD}/${PROGRAM_NAME}.pid"
PID_FILE="/run/${PROGRAM_NAME}.pid"
echo "Process ID (PID) stored in "${PID_FILE}" ..."

# LOG_FILE="${PWD}/${PROGRAM_NAME}.log"
LOG_FILE="/tmp/${PROGRAM_NAME}.log"
echo "Logs stored in ${LOG_FILE} ..."

#
# OPTIONS
#

# --background	 Continue in background	after startup
BACKGROUND=true

#
# Include VPN server configuration file
#
source ./open-vpn-conf.sh

function start(){
	if [ ! is_network_available	]; then	
		printf "Network	is not available! Please check your	internet connection.\n"
		exit 1
	fi

	if [ is_vpn_running	]; then
		printf "OpenConnect	VPN	is already running ...\n"
		exit 1
	fi

	echo "Which	VPN	do you want	to connect to ?"
	options=("$VPN1_NAME" "$VPN2_NAME" "Quit")
	select option in "${options[@]}"; do
		case $option in
			"$VPN1_NAME")
				export VPN_NAME=$VPN1_NAME
				export VPN_HOST=$VPN1_HOST
				export VPN_GROUP=$VPN1_AUTHGROUP
				export VPN_USER=$VPN1_USER
				export VPN_PASSWD=$VPN1_PASSWD
				export VPN_SERVER_CERTIFICATE=$VPN1_SERVER_CERTIFICATE
				export VPN_PROTOCOL=$VPN1_PROTOCOL
				connect
				break
				;;

			"$VPN2_NAME")
				export VPN_NAME=$VPN2_NAME
				export VPN_HOST=$VPN2_HOST
				export VPN_GROUP=$VPN2_AUTHGROUP
				export VPN_USER=$VPN2_USER
				export VPN_PASSWD=$VPN2_PASSWD
				export VPN_SERVER_CERTIFICATE=$VPN2_SERVER_CERTIFICATE
				export VPN_PROTOCOL=$VPN2_PROTOCOL
				connect
				break
				;;

			"Quit")
				echo "User requested exit!"
				exit
				;;

			*)
				echo "Invalid option $REPLY"
				;; 
		esac

		if [ is_vpn_running	]; then	
			printf "OpenConnect	VPN	is connected ...\n"
			print_current_ip_address
			break
		else
			printf "OpenConnect	VPN	failed to connect!\n"
		fi
	done
}

function connect() {
	if [[ -z "${VPN_HOST}" ]]; then
		echo "[VPN_HOST] environment variable not defined!"
		return
	fi
	if [[ -z "${VPN_PROTOCOL}" ]]; then
		echo "[VPN_VPN_PROTOCOL] environment variable not defined!"
		return
	fi
	
	case "${VPN_PROTOCOL}" in
		"anyconnect")
			export VPN_PROTOCOL_DESCRIPTION="Cisco AnyConnect SSL VPN"
			;;
		"nc")
			export VPN_PROTOCOL_DESCRIPTION="Juniper Network Connect"
			;;
		"gp")
			export VPN_PROTOCOL_DESCRIPTION="Palo Alto Networks	(PAN) GlobalProtect	SSL	VPN"
			;;
		"pulse")
			export VPN_PROTOCOL_DESCRIPTION="Pulse Connect Secure SSL VPN"
			;;
	esac
		
	echo "Starting the ${VPN_NAME} on ${VPN_HOST} using	${VPN_PROTOCOL_DESCRIPTION}	..."
	

	if [ ""${VPN_SERVER_CERTIFICATE}"" = ""	]; then
		echo "Connecting without server	certificate	..."
		if [ "$BACKGROUND" = true ]; then
			echo "Running the ${VPN_NAME} in background	..."
			echo "${VPN_PASSWD}" | sudo	openconnect	--VPN_PROTOCOL="${VPN_PROTOCOL}" --background -q "${VPN_HOST}" --user="${VPN_USER}"	--authgroup="${VPN_GROUP}" --passwd-on-stdin --pid-file	"${PID_FILE}" >	"${LOG_FILE}" 2>&1
		else
			echo "Running the ${VPN_NAME} ..."
			echo "${VPN_PASSWD}" | sudo	openconnect	--VPN_PROTOCOL="${VPN_PROTOCOL}" -q	"${VPN_HOST}" --user="${VPN_USER}" --authgroup="${VPN_GROUP}" --passwd-on-stdin	--pid-file "${PID_FILE}" > "${LOG_FILE}" 2>&1
		fi
	else
		echo "Connecting with certificate ..."
		if [ "$BACKGROUND" = true ]; then
			echo "Running the ${VPN_NAME} in background	..."
			echo "${VPN_PASSWD}" | sudo	openconnect	--VPN_PROTOCOL="${VPN_PROTOCOL}" --background -q "${VPN_HOST}" --user="${VPN_USER}"	--authgroup="${VPN_GROUP}" --passwd-on-stdin --servercert="${VPN_SERVER_CERTIFICATE}" --pid-file "${PID_FILE}" > "${LOG_FILE}" 2>&1
		else
			echo "Running the ${VPN_NAME} ..."
			echo "${VPN_PASSWD}" | sudo	openconnect	--VPN_PROTOCOL="${VPN_PROTOCOL}" -q	"${VPN_HOST}" --user="${VPN_USER}" --authgroup="${VPN_GROUP}" --passwd-on-stdin	--servercert="${VPN_SERVER_CERTIFICATE}" --pid-file	"${PID_FILE}" >	"${LOG_FILE}" 2>&1
		fi
	fi

	status
}

function status() {
	is_vpn_running && printf "OpenConnect VPN is running ...\n"	|| printf "OpenConnect VPN is stopped ...\n"
	print_current_ip_address
}

function stop()	{
	if [ is_vpn_running	]; then
		echo "OpenConnect VPN is running ..."
		echo "Removing ${PID_FILE} ..."
		
		# kill -9 $(pgrep openconnect) > /dev/null 2>&1
		local pid=$(cat	$PID_FILE)
		kill -9	$pid > /dev/null 2>&1
		rm -f $PID_FILE	> /dev/null	2>&1
	fi
	
	printf "OpenConnect	VPN	is disconnected!\n"
	print_current_ip_address
}

function print_info() {
	echo "Usage: $(basename	"$0") (start|stop|status|restart)"
}

function is_network_available()	{
	ping -q	-c 1 -W	1 8.8.8.8 >	/dev/null 2>&1;
}

function is_vpn_running() {
	test -f	"${PID_FILE}" && return	0
	# local pid=$(cat $PID_FILE)
	# kill -0 $pid > /dev/null 2>&1
}

function print_current_ip_address()	{
	local ip=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com)
	printf "Your IP	address	is:	${ip} \n"
}

case "$1" in
	start)
		start
		;;
	
	stop)
		stop
		;;
	
	status)
		status
		;;
	
	restart)
		$0 stop
		$0 start
		;;
	
	*)
		print_info
		exit 0
		;;
esac
