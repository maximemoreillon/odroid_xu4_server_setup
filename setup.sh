#!/bin/bash

echo "Home server setup"

# Permission check
echo -n "- Checking permissions: "
if [[ $EUID -eq 0 ]]
then
   echo -e "\e[32mOK\e[39m"
 else
   echo -e "\e[31mERROR\e[39m"
   exit 1
fi

# Update and upgrate
echo "- Initial update and upgrade"

echo -n "-- apt-get update: "
apt-get -qq update &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

echo -n "-- Installing dialog: "
apt-get -qq -y install dialog &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

echo -n "-- apt-get upgrade: "
apt-get -qq -y upgrade && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; } # Do not silence this because of boot ini change

echo -n "-- apt-get dist-upgrade: "
apt-get -qq -y dist-upgrade && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; } # Do not silence this because of boot ini change

echo -n "-- linux-image-xu3: "
apt-get -qq -y install linux-image-xu3 && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; } # Do not silence this because of boot ini change

# Run all scripts
echo "- Server setup"
/bin/bash ./hdd_setup.sh
/bin/bash ./samba_setup.sh
/bin/bash ./duckdns_setup.sh
/bin/bash ./lamp_setup.sh
/bin/bash ./nextcloud_setup.sh
/bin/bash ./ssl_setup.sh
/bin/bash ./hass_setup.sh
