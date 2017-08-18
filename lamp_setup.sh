#!/bin/bash

echo "- LAMP server setup"

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

# MariaDB credentials
echo -n "-- Retrieving secrets: "
source ./secrets.conf && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

mariadb_root_password=$PASSWORD

# Files location
default_http_conf="default_http.conf"
default_http_conf_source="./configuration_files/apache_files/$default_http_conf"
default_http_conf_destination="/etc/apache2/sites-available/$default_http_conf"


# Packages install
echo -n "-- Packages installation: "
apt-get -qq -y install apache2 php mariadb-server libapache2-mod-php php-mysql &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Apache2 configuration
echo "-- Apache configuration"
echo "--- Moving new Apache default configuration file"
/bin/bash ./copy_with_backup.sh $default_http_conf_source $default_http_conf_destination

echo "--- Disabling original apache configuration"
a2dissite 000-default.conf &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

echo "--- Enabling new apache configuration"
a2ensite $default_http_conf &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Maria DB secure installation
echo -n "-- MariaDB configuration"
mysql -uroot -p$mariadb_root_password -e "UPDATE mysql.user SET Password = PASSWORD('$mariadb_root_password') WHERE User = 'root'" &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
mysql -uroot -p$mariadb_root_password -e "DELETE FROM mysql.user WHERE User=''" &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
mysql -uroot -p$mariadb_root_password -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')" &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
mysql -uroot -p$mariadb_root_password -e "DROP DATABASE IF EXISTS test" &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
mysql -uroot -p$mariadb_root_password -e "FLUSH PRIVILEGES" &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
echo -e "\e[32mOK\e[39m"
