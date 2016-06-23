#!/bin/bash

WORK_PATH=/root
mmc=mmcblk2p1

usb_emmc_test()
{
	insmod modules/libcomposite.ko
	insmod modules/usb_f_mass_storage.ko
	insmod modules/g_mass_storage.ko file=/dev/mmcblk2p1 stall=0 removable=1,1	
}

if [ ! -e /dev/mmcblk2p1 ] ; then 
	echo -e "\n\033[31mFAIL\033[0m\n"
	exit 1 ; 
fi

usb_emmc_test

echo -e "\033[33m--Do you see the removable device on PC?--\033[0m"
echo -e "\033[33m--(Y/N)?--\033[0m"

read var

if [ "$var" == "Y" ] || [ "$var" == "y" ]; then 
	echo -e "\033[32mPASS\n\033[0m"
	exit 0
else
	echo -e "\n\033[31mFAIL\033[0m\n"
	exit 1
fi
