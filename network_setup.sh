#!/bin/bash

echo "- Network setup"

# Check if run as root
echo -n "-- Checking permissions: "
if [[ $EUID -eq 0 ]]
then
   echo -e "\e[32mOK\e[39m"
 else
   echo -e "\e[31mERROR\e[39m"
   exit 1
fi

# Files
interfaces_source="./configuration_files/interfaces"
interfaces_destination="/etc/network/interfaces"

# Replacing samba config file
echo "-- Network configuration"
/bin/bash ./copy_with_backup.sh $interfaces_source $interfaces_destination
