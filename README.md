# vpn-shell-for-openconnect

A VPN shell script for openconnect on Linux

## Features

A shell script for openconnect which allows:

- to define multiple VPN connections, using different protocols
- to run openconnect without entering the username and password
- to run in the background
- to authenticate with a certiftcate
- to check the status of the vpn connection

## What's new

- added support for using different protocols
- added options (start, stop, status, restart)
- can check status of the vpn connection

## Last modifications

- reformat all code style, refactor some variable name
- reformat all the space characters to [Tab] character, although I prefer to use space characters
- change the path of the PID file and log file, like "/run/xxxxx.pid", "/tmp/xxxxx.log"
- split VPN server configuration to "open-vpn-conf.sh" file

**Last modified**: `shines77` / `2022-03-22`

## Sample configuration section

Edit your configurtion file:

```shell
vim open-vpn-conf.sh
```

The content is modified to like below:

```bash
# If you don't want to run in background, so make this false
BACKGROUND=true

# Company VPN
export VPN1_NAME="My Company VPN"
export VPN1_PROTOCOL="anyconnect"
export VPN1_HOST="vpn.mycompany.com"
export VPN1_AUTHGROUP="developers"
export VPN1_USER="sorin.ipate"
export VPN1_PASSWD="MyPassword"
# If you don't have server certificate so don't fill this
export VPN1_SERVER_CERTIFICATE="SHA1-OtherCharachters"
```

## How to use

Here just demonstrate how to use this code in Ubuntu

### 1. Install openconnect

```shell
sudo apt-get update
sudo apt-get install openconnect
```

### 2. Install openconnect

## Run VPN shell script

1. Please make sure you have `openconnect` installed before moving on. Follow the instructions [here](https://formulae.brew.sh/formula/openconnect).

2. [Download the latest release](https://github.com/shines77/vpn-shell-for-openconnect/releases/download/v1.0-alpha/vpn-shell-for-openconnect-master.zip).

3. Copy the "`open-vpn-cmd.sh`" and "`open-vpn-conf.sh`" file to the "`\usr\bin`" folder.

4. Update the "`open-vpn-cmd.sh`" file with the appropiate VPN connection information as shown above.

5. Make an alias `alias open-vpn-cmd='~/bin/open-vpn-cmd.sh'` in `bash` or `zsh` shell. Follow the instructions [here](https://wpbeaches.com/make-an-alias-in-bash-or-zsh-shell-in-macos-with-terminal/?__cf_chl_jschl_tk__=60015f4af93b104457efe3f2c7cd70de60ea05aa-1620807543-0-Ab8kPRiPbnWqJwPgGZ3k9zQ7t6ZrVnGiWZZGwLH1zmtS0Z2_I9_4k3484HAUDxe0WrYTgXZcYJg86SM895qayJYySOYhh0XdTBtOZwfa-KKLrgR-KJ9rvQmIas6UVdqHdedjUmCgljtFoxzGKguvu1TZ0NA_WAt8FrrfYo8aYhaXFXFVPkhvarI2mI1vWHc06ROepAwLTHfibEXn6VIiC02c0s3RD_5h_NsByw_6eWHESbqdUTnahAA-ls6lgQ7wY556EShckoVIvPGgnLWlYb4diIXOKntvTKMrPAtndHnB1oGY9RC8tZlfDlRrdnB4d6aaKgyp1uKgL77BPmmuRP9TDI3cnqGJoKc9_-Og5t5H2mOPjgo7La9F6Nja6Pn6jnyExLDsYvoASWdOG6mlYdP8IVQ9MXKJcoYphsdiZNuv4WxieW9GY7rPIdMQ0y2Rq9Rae04fi0JFl7GdQKEbC0uEY5umB5Bd9Dsc1aY6xb85).

6. Run `open-vpn-cmd` to start and voila.
