#!/bin/bash

echo "- Odroid XU4 Setup"

# Permission check
echo -n "-- Checking permissions: "
if [[ $EUID -eq 0 ]]
then
   echo -e "\e[32mOK\e[39m"
 else
   echo -e "\e[31mERROR\e[39m"
   exit 1
fi

# Update and upgrate
echo -n "-- apt-get update: "
apt-get -qq update &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

echo -n "-- Installing dialog: "
apt-get -qq -y install dialog &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

echo -n "-- apt-get upgrade: "
apt-get -qq -y upgrade # Do not silence this because of boot ini change

echo -n "-- apt-get dist-upgrade: "
apt-get -qq -y dist-upgrade # Might be wise not to silence this one too

echo -n "-- linux-image-xu3: "
apt-get -qq -y install linux-image-xu3

echo -n "-- Bash autocompletion: "
apt-get -qq -y install  bash-completion &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; } # Do not silence this because of boot ini change
