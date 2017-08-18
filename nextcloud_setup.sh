#!/bin/bash

### Parameters

## Files
# Nextcloud install files
nextcloud_url="https://download.nextcloud.com/server/releases/nextcloud-12.0.0.tar.bz2"
nextcloud_destination="/var/www/nextcloud"

# Nextcloud apache2 configuration file
nextcloud_conf="nextcloud.conf"
nextcloud_conf_source="./configuration_files/apache_files/$nextcloud_conf"
nextcloud_conf_destination="/etc/apache2/sites-available/$nextcloud_conf"

## MariaDB Parameters
source ./secrets.conf
mariadb_root_password=$PASSWORD
mariadb_nextcloud_username="nextcloud"
mariadb_nextcloud_password=$PASSWORD
mariadb_nextcloud_database_name="nextcloud"

echo "- NextCloud setup"

# Check if run as root
echo -n "-- Checking permissions: "
if [[ $EUID -eq 0 ]]
then
   echo -e "\e[32mOK\e[39m"
 else
   echo -e "\e[31mERROR\e[39m"
   exit 1
fi

# Check if nextcloud not installed previously
echo -n "-- Checking for previous installment: "
if [ -d "$nextcloud_destination" ]
then
  # If Nextcloud already installed
  echo -e "\e[31mNEXTCLOUD ALREADY INSTALLED\e[39m"
  exit 1
else
  # If no installment found
  echo -e "\e[32mOK\e[39m"
fi


echo "-- Installing NextCloud"

# Doanloading nextcloud
echo -n "--- Downloading NextCloud: "
wget -q $nextcloud_url &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Extracting NextCloud
echo -n "--- Extracting NextCloud: "
tar xjf nextcloud-* &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

echo -n "--- Moving NextCloud to Apache document root: "
mv nextcloud $nextcloud_destination &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Setting up files permissions
echo -n "--- Setting ownership of $nextcloud_destination: "
chown -R www-data:www-data $nextcloud_destination &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Cleanup install files
echo -n "--- Cleanup: "
rm nextcloud-* &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }


# Installing reqauired PHP modules
echo -n "-- Installing required PHP modules: "
apt-get -qq -y install php-mysql php-curl php-json php-mcrypt php-intl php-imagick php-gd php-zip php-xml php-mbstring &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Apache configuration
# Redirect requests on /nextcloud to the nextcloud directory
echo "-- Apache2 configuration"
echo "--- Adding site"
/bin/bash ./copy_with_backup.sh $nextcloud_conf_source $nextcloud_conf_destination

echo -n "--- Enabling site"
a2ensite $nextcloud_conf &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

echo -n "--- Enabling new Apache2 modules: "
a2enmod rewrite &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
a2enmod headers &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
a2enmod env &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
a2enmod dir &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
a2enmod mime &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
echo -e "\e[32mOK\e[39m"

echo -n "--- Restarting Apache2: "
service apache2 restart &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# MariaDB configuration
# Creates user and database for nextcloud
echo -n "-- MariaDB configuration: "
mysql -uroot -p$mariadb_root_password -e "CREATE DATABASE IF NOT EXISTS $mariadb_nextcloud_database_name" &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
mysql -uroot -p$mariadb_root_password -e "CREATE USER $mariadb_nextcloud_username@localhost IDENTIFIED BY '$mariadb_nextcloud_password'" &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
mysql -uroot -p$mariadb_root_password -e "GRANT ALL PRIVILEGES ON $mariadb_nextcloud_database_name.* TO '$mariadb_nextcloud_username'@'localhost' IDENTIFIED BY '$mariadb_nextcloud_password'" &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
mysql -uroot -p$mariadb_root_password -e "FLUSH PRIVILEGES" &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
echo -e "\e[32mOK\e[39m"

# Install finished
echo "- Nextcloud install complete, please run the install wizard"
