#!/bin/bash

# Checks if destination exists, if so check if its backup exists, if not backs up destination
# then proceeds to copy source to destination

source=$1
destination=$2

echo "Making backup of $destination if necessary and copy $source to $destination"

# Check if backup necessary
echo -n "- Checking if $destination exists: "
if [ -f $destination ]
then
  # Destination file already exists
  echo "$destination EXISTS"

  # Check if original file isn't backed up already
  echo -n "-- Checking if backup of $destination exists: "
  if [ -f $destination.original ]
  then
  	# If backup exists, don't backup again
  	echo "BACKUP EXISTS"
  else
  	# If backup doesn't exist
  	echo "BACKUP DOES NOT EXIST"

  	# Backup doesn not exist so create backup
  	echo -n "--- Backing up $destination: "
  	cp $destination $destination.original &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }
  fi
else
	# If destination file does not exist
	echo "$destination DOES NOT EXIST"
fi

# If a backup was needed, it has been done so now the copy can happen
echo -n "- Copying $source to $destination: "
cp -p $source $destination &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }
