#!/bin/bash

echo "- Home Assistant setup"

# Check if run as root
echo -n "-- Checking permissions: "
if [[ $EUID -eq 0 ]]
then
   echo -e "\e[32mOK\e[39m"
 else
   echo -e "\e[31mERROR\e[39m"
   exit 1
fi

### Parameters

echo -n "-- Retrieving secrets: "
source ./secrets.conf && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

mosquitto_username=$USERNAME
mosquitto_password=$PASSWORD

## files
# Mosquitto config file
mosquitto_conf_source="./configuration_files/mosquitto.conf"
mosquitto_conf_destination="/etc/mosquitto/mosquitto.conf"

# Systemd service file for autostart
home_assistant_service="home-assistant@homeassistant.service"
home_assistant_service_source="./configuration_files/$home_assistant_service"
home_assistant_service_destination="/etc/systemd/system/$home_assistant_service" # CHECK THIS ONE

# Apache site
hass_conf="hass.conf"
hass_conf_source="./configuration_files/apache_files/$hass_conf"
hass_conf_destination="/etc/apache2/sites-available/$hass_conf"

## Misc
mosquitto_password_file="/etc/mosquitto/passwd"


echo "-- Home assistant installation"

# Packages
echo -n "-- Installing packages: "
apt-get -y -qq install python-pip python3-dev &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
pip install --upgrade virtualenv &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
echo -e "\e[32mOK\e[39m"

# Creat homeassistant user
echo -n "-- Creating homeassistant user: "
adduser --system homeassistant &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
addgroup homeassistant &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
adduser homeassistant homeassistant &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
echo -e "\e[32mOK\e[39m"

# Creat home assistant directory
echo -n "-- Creating homeassistant install directory: "
mkdir /srv/homeassistant || { echo -e "\e[31mERROR\e[39m"; exit 1; }
chown homeassistant:homeassistant /srv/homeassistant || { echo -e "\e[31mERROR\e[39m"; exit 1; }
echo -e "\e[32mOK\e[39m"

# Install per se
echo "-- Installing Home Assistant"
su -s /bin/bash homeassistant <<EOF
  virtualenv -p python3 /srv/homeassistant
  source /srv/homeassistant/bin/activate
  pip3 install --upgrade homeassistant
EOF

## Autostart
echo "-- Setting up autostart"

# Move service file
echo "--- Copying service file"
/bin/bash ./copy_with_backup.sh $home_assistant_service_source $home_assistant_service_destination

# Enable service
echo -n "--- Enabling service file: "
systemctl enable $home_assistant_service &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

## Starting home assistant
echo -n "--- Starting Home Assistant: "
systemctl start $home_assistant_service &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }


## Mosquitto
echo "-- Mosquitto setup"

# Install packages
echo -n "-- Installing Mosquitto: "
apt-get -qq -y install mosquitto mosquitto-clients &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Mosquito configuration
echo "-- Mosquitto configuration"
/bin/bash ./copy_with_backup.sh $mosquitto_conf_source $mosquitto_conf_destination

echo "-- Setting up Mosquitto authentication"
( echo $mosquitto_password; echo $mosquitto_password ) | mosquitto_passwd -c $mosquitto_password_file $mosquitto_username

# Apache configuration
echo "-- Apache configuration"

# Apache reverse proxy settings
echo -n "--- Enabling apache modules: "
a2enmod proxy &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
a2enmod proxy_http &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
a2enmod proxy_wstunnel &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
echo -e "\e[32mOK\e[39m"

# Adding hass site
echo "--- Copying apache site"
/bin/bash ./copy_with_backup.sh $hass_conf_source $hass_conf_destination

echo -n "--- Enabling apache site: "
a2ensite $hass_conf &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

echo -n "--- Restarting apache: "
service apache2 restart &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }
