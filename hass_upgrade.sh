#!/bin/bash

echo "Home Assistant upgrade"


# Systemd service file for autostart
home_assistant_service="/etc/systemd/system/home-assistant@homeassistant.service"

# Check if run as root
echo -n "- Checking permissions: "
if [[ $EUID -eq 0 ]]
then
   echo -e "\e[32mOK\e[39m"
 else
   echo -e "\e[31mERROR\e[39m"
   exit 1
fi

echo -n "- Stopping Home Assistant: "
systemctl stop $home_assistant_service &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

echo "- Upgrading Home Assistant: "
su -s /bin/bash homeassistant <<EOF
  source /srv/homeassistant/bin/activate
  pip3 install --upgrade homeassistant
EOF

echo -n "-Restarting Home Assistant: "
systemctl start $home_assistant_service &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }
