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

# Run all scripts
/bin/bash ./odroid_setup.sh
/bin/bash ./hdd_setup.sh
/bin/bash ./samba_setup.sh
/bin/bash ./duckdns_setup.sh
/bin/bash ./lamp_setup.sh
/bin/bash ./nextcloud_setup.sh
/bin/bash ./ssl_setup.sh
/bin/bash ./hass_setup.sh
