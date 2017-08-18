#!/bin/bash

echo "- Samba setup"

# Check if run as root
echo -n "-- Checking permissions: "
if [[ $EUID -eq 0 ]]
then
   echo -e "\e[32mOK\e[39m"
 else
   echo -e "\e[31mERROR\e[39m"
   exit 1
fi

## Parameters

# Credentials
echo -n "-- Retrieving secrets: "
source ./secrets.conf && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }
samba_username=$USERNAME
samba_password=$PASSWORD

# Files
smbconf_source="./configuration_files/smb.conf"
smbconf_destination="/etc/samba/smb.conf"


# Installing packages
echo -n "-- Installing packages: "
apt-get -qq -y install samba &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Replacing samba config file
echo "-- Samba configuration"
/bin/bash ./copy_with_backup.sh $smbconf_source $smbconf_destination

# Adding user to samba users
echo "-- Adding $samba_username to samba users"
( echo $samba_password; echo $samba_password ) | smbpasswd -a -s $samba_username
