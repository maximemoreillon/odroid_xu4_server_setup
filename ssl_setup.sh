#!/bin/bash

echo "- SSL setup"

# Check if run as root
echo -n "-- Checking permissions: "
if [[ $EUID -eq 0 ]]
then
   echo -e "\e[32mOK\e[39m"
 else
   echo -e "\e[31mERROR\e[39m"
   exit 1
fi

# Parameters
default_https_conf_name="default_https"
default_https_conf_source="./configuration_files/apache_files/$default_https_conf_name.conf"
default_https_conf_destination="/etc/apache2/sites-available/$default_https_conf_name.conf"

# Certbot
echo "-- Certbot"
echo -n "--- Installing packages for Certbot"
apt-get install software-properties-common || { echo -e "\e[31mERROR\e[39m"; exit 1; }
add-apt-repository ppa:certbot/certbot || { echo -e "\e[31mERROR\e[39m"; exit 1; }
apt-get update || { echo -e "\e[31mERROR\e[39m"; exit 1; }
apt-get install python-certbot-apache || { echo -e "\e[31mERROR\e[39m"; exit 1; }
echo -e "\e[32mOK\e[39m"

echo "--- Running Certbot"
certbot --apache certonly

# Apache2 configuration
echo "-- Apache2 configuration"

# Replacing default-ssl.conf configuration file
echo "--- Copying Apache configuration files"
/bin/bash ./copy_with_backup.sh $default_https_conf_source $default_https_conf_destination

# Activation of the new Apache2 configuration
echo -n "--- Enabling new Apache2 configuration: "
a2enmod ssl &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
a2ensite $default_https_conf_name &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
service apache2 restart &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
echo -e "\e[32mOK\e[39m"
