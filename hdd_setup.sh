#!/bin/bash

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
hdd_1_label="NAS_HDD_1"
hdd_1_mounting_point="/mnt/nas_hdd_1"

hdd_2_label="NAS_HDD_2"
hdd_2_mounting_point="/mnt/nas_hdd_2"

fstab_path="/etc/fstab"

echo "- Setting up HDD"

# Create mounting point directory
echo -n "-- Creating mounting points: "
mkdir $hdd_1_mounting_point 2>/dev/null && mkdir $hdd_2_mounting_point &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }

# Setting up fstab
echo "-- Setting up fstab"

# Checks if fstab needs to be backed up
echo -n "--- Checking if fstab backup exists: "
if [ -f $fstab_path.original ]
then
	# Already backed up means fstab already modified so stop here
	echo -e "\e[31mBACKUP ALREADY EXISTS\e[39m"
  exit 1
else
  echo -e "\e[32mBACKUP DOES NOT EXIST\e[39m"

	# If not backed up already, backup
  echo -n "--- Backing up fstab: "
	cp $fstab_path $fstab_path.original &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }
fi

# Edit fstab file
echo -n "--- Adding entries to $fstab_path: "
echo "" | tee -a $fstab_path &>/dev/null
echo "# NAS Hard drives" | tee -a $fstab_path &>/dev/null
echo "LABEL=$hdd_1_label  $hdd_1_mounting_point  ext4  defaults,nofail,noatime 0 0" | tee -a $fstab_path &>/dev/null
echo "LABEL=$hdd_2_label  $hdd_2_mounting_point  ext4  defaults,nofail.noatime 0 0" | tee -a $fstab_path &>/dev/null
echo "" | tee -a $fstab_path &>/dev/null
echo -e "\e[32mOK\e[39m"

# Apply the fstab to mount drives
echo -n "-- Mounting drives: "
mount -a &>/dev/null && echo -e "\e[32mOK\e[39m" || { echo -e "\e[31mERROR\e[39m"; exit 1; }
