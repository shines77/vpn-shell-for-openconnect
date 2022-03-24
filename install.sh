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

# set -x

if [ -n "${1}" ]; then
	Install_To_Folder="${1}"
else
	Install_To_Folder="${HOME}/bin"
	if [ ! -d "${Install_To_Folder}" ]; then
		sudo mkdir "${Install_To_Folder}"
	fi
fi

if [ -d "${Install_To_Folder}" ]; then
	sudo cp -i ${PWD}/open-vpn-cmd.sh ${Install_To_Folder}/open-vpn-cmd.sh
	sudo cp -i ${PWD}/open-vpn-conf.sh ${Install_To_Folder}/open-vpn-conf.sh

	sudo chmod +x ${Install_To_Folder}/open-vpn-cmd.sh

	alias open-vpn-cmd="${Install_To_Folder}/open-vpn-cmd.sh"

	set +x
	echo "------------------------------------------------------------------------------------"
	echo "[vpn-shell-for-openconnect]: Install success. already install to ${Install_To_Folder} folder."
	echo "------------------------------------------------------------------------------------"
	set -x
else
	set +x
	echo "------------------------------------------------------------------------------------"
	echo "[vpn-shell-for-openconnect]: Install failed, ${Install_To_Folder} folder is not existed."
	echo "------------------------------------------------------------------------------------"
	set -x
fi
