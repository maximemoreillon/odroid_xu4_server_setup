#!/bin/bash

echo "- Setting up DuckDNS"

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
crontab_path="/etc/crontab"

echo -n "-- Retrieving secrets: "
source ./secrets.conf && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Token and domains retrieved from secrets
duckdns_token=$DUCKDNS_TOKEN
duckdns_domains=$DUCKDNS_DOMAINS

# cURL install
echo -n "-- cURL installation: "
apt-get -qq -y install curl &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Setting up cron jobs
echo -n "-- Setting up cron jobs: "
for duckdns_domain in "${duckdns_domains[@]}"
do
        echo  '*/5 * * * * root echo url="https://www.duckdns.org/update?domains='$duckdns_domain'&token='$duckdns_token'&ip=" | curl -k -K - &>/dev/null\n' | tee -a $crontab_path &>/dev/null || { echo -e "\e[31mERROR\e[39m"; exit 1; }
done
echo -e "\e[32mOK\e[39m"
