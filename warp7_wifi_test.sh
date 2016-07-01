#!/bin/bash
WORK_PATH=/root
mmc=mmcblk2p1
file=log_file.txt
log_to_file()
{
        echo -1 > /proc/sys/kernel/printk
}

log_to_std()
{
        echo 8 > /proc/sys/kernel/printk
}

wifi_init()
{
	ifconfig wlan0 down
	kill `pidof wpa_supplicant` > /dev/null
}

wifi_test()
{
        mkdir -p /lib/firmware
        cp mmc/bcm /lib/firmware/ -r
        insmod modules/bcmdhd.ko
        wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf -D nl80211
        wpa_cli scan
}

wifi_connect()
{
        C=`wpa_cli status | grep COMPLETED`

        if [ ! -z $C ] ; then
                dhcpcd
                return 6
        fi
}

wifi_loop()
{
        for ((COUNTER=0; COUNTER<5; ++COUNTER))  
        do
                wpa_cli scan
                log_to_std
                wpa_cli scan_result
                log_to_file
                wait
                sleep 2

                wifi_connect
		is_connected=$?
                sleep 3
                if [ 6 = $is_connected ] ; then
                       ping -c 3 192.168.2.1 > /dev/null
                       if [ 0 = $? ] ; then
				return 0
			fi
                fi
        done
	return 1 #this means that we can not find the ava ap
}

wifi_init
wifi_test
wifi_loop

return_code=$?

if [ $return_code == 1 ]; then
         echo -e "\n\033[31mFAIL\033[0m\n"
         exit 1

elif [ $return_code == 0 ] ; then
        echo -e "\033[32mPASS\n\033[0m"
        exit 0
fi

