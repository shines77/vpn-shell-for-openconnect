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

# Resolve $PROGRAM_SOURCE until the file is no longer a symlink
PROGRAM_SOURCE="${0}"
while [ -h "$PROGRAM_SOURCE" ]; do
    PROGRAM_DIR="$( cd -P "$( dirname "$PROGRAM_SOURCE" )" && pwd )"
    PROGRAM_SOURCE="$(readlink "$PROGRAM_SOURCE")"
    # If $PROGRAM_SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    [[ $PROGRAM_SOURCE != /*  ]] && PROGRAM_SOURCE="$DIR/$PROGRAM_SOURCE"
done
PROGRAM_DIR="$( cd -P "$( dirname "$PROGRAM_SOURCE" )" && pwd )"

PROGRAM_NAME=$(basename	$0)
echo "Starting ${PROGRAM_NAME} ..."

if [ ! -f "${PROGRAM_DIR}/open-vpn-my-conf.sh" ]; then
	echo "--------------------------------------------------------------"
	echo ""
	echo "[vpn-shell-for-openconnect]:"
	echo ""
	echo "  Error: The [open-vpn-conf.sh] file does not exist."
	echo ""
	echo "--------------------------------------------------------------"
	echo ""
	echo "  Change the path to your [vpn-shell-for-openconnect] git repo dir:"
	echo ""
	echo "    cd <Your git repository dir>/vpn-shell-for-openconnect"
	echo ""
	echo "  Copy the original configuration file:"
	echo ""
	echo "    cp ./open-vpn-original-conf.sh ./open-vpn-my-conf.sh"
	echo ""
	echo "  And edit it use your configuration:"
	echo ""
	echo "    vim ./open-vpn-my-conf.sh"
	echo ""
	echo "  Then install the configuration file:"
	echo ""
	echo "    ./install.sh"
	echo ""
	echo "--------------------------------------------------------------"
	exit 1
fi

CMD_ACTION="${1}"

# PID_FILE="${PWD}/${PROGRAM_NAME}.pid"
PID_FILE="/run/${PROGRAM_NAME}.pid"
if [ CMD_ACTION == "start" ]; then
	echo "Process ID (PID) stored in "${PID_FILE}" ..."
fi

# LOG_FILE="${PWD}/${PROGRAM_NAME}.log"
LOG_FILE="/tmp/${PROGRAM_NAME}.log"
if [ CMD_ACTION == "start" ]; then
	echo "Logs stored in ${LOG_FILE} ..."
fi

SCRIPT_LOG_FILE="/tmp/${PROGRAM_NAME}.script.log"

# echo "PROGRAM_SOURCE: ${0}"
# echo "PROGRAM_DIR: ${PROGRAM_DIR}"
# echo "PROGRAM_NAME: ${PROGRAM_NAME}"
# echo "PWD: ${PWD}"

#
# OPTIONS
#

# --background	 Continue in background	after startup
BACKGROUND=true

#
# Include VPN server configuration file
#
source "${PROGRAM_DIR}"/open-vpn-conf.sh

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "${SCRIPT_LOG_FILE}" 2>&1
echo "`date`: open-vpn-cmd.sh start to running." >> "${SCRIPT_LOG_FILE}" 2>&1
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "${SCRIPT_LOG_FILE}" 2>&1

# set -x

function start() {
	if ! is_network_available; then
		printf "Network is not available! Please check your internet connection.\n"
		exit 1
	fi

	if is_vpn_running; then
		printf "OpenConnect VPN is already running ...\n"
		exit 1
	fi

	echo "Which VPN do you want to connect to ?"
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

		if is_vpn_running; then
			printf "OpenConnect VPN is connected ...\n"
			print_current_ip_address
			break
		else
			printf "OpenConnect VPN failed to connect!\n"
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
			export VPN_PROTOCOL_DESCRIPTION="Juniper Network Connec
			t"
			;;
		"gp")
			export VPN_PROTOCOL_DESCRIPTION="Palo Alto Networks (PAN) GlobalProtect SSL VPN"
			;;
		"pulse")
			export VPN_PROTOCOL_DESCRIPTION="Pulse Connect Secure SSL VPN"
			;;
	esac
		
	echo "Starting the ${VPN_NAME} on ${VPN_HOST} using ${VPN_PROTOCOL_DESCRIPTION} ..."
	echo "`date`: Starting the ${VPN_NAME} on ${VPN_HOST} using ${VPN_PROTOCOL_DESCRIPTION} ..." >> "${SCRIPT_LOG_FILE}" 2>&1

	#
	# Exclude your VPN client computer IP,
	# OpenConnect can help us exclude the VPN server IP, so don't worry about it.
	#
	sudo ip route add 155.166.177.188 via 172.16.0.1 dev eth0 src 172.16.0.6
	#
	# Exclude your SSH terminal computer IP, if your computer IP is a Dynamic IP,
	# you can exclude a network range like:
	# 120.0.0.0/8, or 124.0.0.0/8
	#
	sudo ip route add 120.0.0.0/8 via 172.16.0.1 dev eth0 src 172.16.0.6
	sudo ip route add 124.0.0.0/8 via 172.16.0.1 dev eth0 src 172.16.0.6

	set -xv
	if [ "${VPN_SERVER_CERTIFICATE}" = "" ]; then
		echo "Connecting without server certificate ..."
		if [ "${VPN_GROUP}" = "" ]; then
			if [ "$BACKGROUND" = true ]; then
				echo "Running the ${VPN_NAME} in background ..."
				set_add_xv
				echo "${VPN_PASSWD}" | sudo openconnect --protocol="${VPN_PROTOCOL}" --background -q "${VPN_HOST}" --user="${VPN_USER}" --passwd-on-stdin --pid-file="${PID_FILE}" > "${LOG_FILE}" 2>&1
				set_remove_xv
			else
				echo "Running the ${VPN_NAME} ..."
				set_add_xv
				echo "${VPN_PASSWD}" | sudo openconnect --protocol="${VPN_PROTOCOL}" -q "${VPN_HOST}" --user="${VPN_USER}" --passwd-on-stdin --pid-file="${PID_FILE}" > "${LOG_FILE}" 2>&1
				set_remove_xv
			fi
		else
			if [ "$BACKGROUND" = true ]; then
				echo "Running the ${VPN_NAME} in background ..."
				set_add_xv
				echo "${VPN_PASSWD}" | sudo openconnect --protocol="${VPN_PROTOCOL}" --background -q "${VPN_HOST}" --user="${VPN_USER}" --authgroup="${VPN_GROUP}" --passwd-on-stdin --pid-file="${PID_FILE}" > "${LOG_FILE}" 2>&1
				set_remove_xv
			else
				echo "Running the ${VPN_NAME} ..."
				set_add_xv
				echo "${VPN_PASSWD}" | sudo openconnect --protocol="${VPN_PROTOCOL}" -q "${VPN_HOST}" --user="${VPN_USER}" --authgroup="${VPN_GROUP}" --passwd-on-stdin --pid-file="${PID_FILE}" > "${LOG_FILE}" 2>&1
				set_remove_xv
			fi
		fi
	else
		echo "Connecting with certificate ..."
		if [ "${VPN_GROUP}" = "" ]; then
			if [ "$BACKGROUND" = true ]; then
				echo "Running the ${VPN_NAME} in background ..."
				set_add_xv
				echo "${VPN_PASSWD}" | sudo openconnect --protocol="${VPN_PROTOCOL}" --background -q "${VPN_HOST}" --user="${VPN_USER}" --passwd-on-stdin --servercert="${VPN_SERVER_CERTIFICATE}" --pid-file="${PID_FILE}" > "${LOG_FILE}" 2>&1
				set_remove_xv
			else
				echo "Running the ${VPN_NAME} ..."
				set_add_xv
				echo "${VPN_PASSWD}" | sudo openconnect --protocol="${VPN_PROTOCOL}" -q "${VPN_HOST}" --user="${VPN_USER}" --passwd-on-stdin --servercert="${VPN_SERVER_CERTIFICATE}" --pid-file="${PID_FILE}" > "${LOG_FILE}" 2>&1
				set_remove_xv
			fi
		else
			if [ "$BACKGROUND" = true ]; then
				echo "Running the ${VPN_NAME} in background ..."
				set_add_xv
				echo "${VPN_PASSWD}" | sudo openconnect --protocol="${VPN_PROTOCOL}" --background -q "${VPN_HOST}" --user="${VPN_USER}" --authgroup="${VPN_GROUP}" --passwd-on-stdin --servercert="${VPN_SERVER_CERTIFICATE}" --pid-file="${PID_FILE}" > "${LOG_FILE}" 2>&1
				set_remove_xv
			else
				echo "Running the ${VPN_NAME} ..."
				set_add_xv
				echo "${VPN_PASSWD}" | sudo openconnect --protocol="${VPN_PROTOCOL}" -q "${VPN_HOST}" --user="${VPN_USER}" --authgroup="${VPN_GROUP}" --passwd-on-stdin --servercert="${VPN_SERVER_CERTIFICATE}" --pid-file="${PID_FILE}" > "${LOG_FILE}" 2>&1
				set_remove_xv
			fi
		fi
	fi
	set +v

	status
}

function stop()	{
	echo "`date`: Stopping the openconnect ..." >> "${SCRIPT_LOG_FILE}" 2>&1

	if is_vpn_running; then
		echo "OpenConnect VPN is running ..."
		echo "Removing ${PID_FILE} ..."
		
		# kill -9 $(pgrep openconnect) > /dev/null 2>&1
		local pid=$(cat $PID_FILE)
		if [ "${pid}" == "" ]; then
			pid=`pidof openconnect`
		fi

		if [ ! "${pid}" == "" ]; then
			kill -9 $pid > /dev/null 2>&1
			rm -f $PID_FILE	> /dev/null 2>&1
		fi
	fi
	
	printf "OpenConnect VPN is disconnected!\n"
	print_current_ip_address
}

function status() {
	is_vpn_running && printf "OpenConnect VPN is running ...\n" || printf "OpenConnect VPN is stopped ...\n"
	print_current_ip_address
}

function print_info() {
	echo "Usage: $(basename "$0") (start|stop|status|restart)"
}

function set_add_xv() {
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "${SCRIPT_LOG_FILE}" 2>&1
	echo "`date`: openconnect start to running." >> "${SCRIPT_LOG_FILE}" 2>&1
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "${SCRIPT_LOG_FILE}" 2>&1
	set -xv
}

function set_remove_xv() {
	set +xv
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "${SCRIPT_LOG_FILE}" 2>&1
	echo "`date`: openconnect start have done." >> "${SCRIPT_LOG_FILE}" 2>&1
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "${SCRIPT_LOG_FILE}" 2>&1
}

function is_network_available() {
	ping -q	-c 1 -W 1 8.8.8.8 > /dev/null 2>&1;
}

function is_vpn_running() {
	test -f "${PID_FILE}" && return 0
	# local pid=$(cat $PID_FILE)
	# kill -0 $pid > /dev/null 2>&1
	pid_of_oc=`pidof openconnect`
	if [ "${pid_of_oc}" == "" ]; then
		return 1
	else
		return 0
	fi
}

function print_current_ip_address() {
	# local ip=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com)
	local ip=`wget -qO- http://ipv4.icanhazip.com; echo`
	printf "Your IP address is: ${ip} \n"
}

case "${1}" in
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

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "${SCRIPT_LOG_FILE}" 2>&1
echo "`date`: open-vpn-cmd.sh end." >> "${SCRIPT_LOG_FILE}" 2>&1
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "${SCRIPT_LOG_FILE}" 2>&1
