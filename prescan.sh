#!/bin/sh

WORK_PATH=/root
mmc=mmcblk2p1
file=log_file.txt

log_to_file()
{
	echo -1 > /proc/sys/kernel/printk
	exec 6>&2
	exec 7>&1
	exec 2>$file
	exec 1>$file
}

log_to_std()
{
	exec 2>&6 6>&-
	exec 1>&7 7>&-
	echo 8 > /proc/sys/kernel/printk
}

println()
{
	log_to_std
	echo $*
	log_to_file
}

goto_workspace()
{
	cd $WORK_PATH
}

check_device()
{
	ls /dev/$1 
	if [ $? -eq 0 ]
		then echo $1 found

	else
		echo "$1 not found!"
		return
	fi
}

mount_mmc()
{
	mkdir $mmc
	check_device mmcblk2p1
	mount /dev/mmcblk2p1 $mmc
}

lcd_test()
{
	check_device fb0
	fbset -yres 319
	./mmc/fb-test 
}

audio_test()
{
	check_device snd/pcmC0D0p
	println "start audio playing"
	aplay mmc/dang.wav
}

audio_loop()
{
	while true
	do
		audio_test
		wait
	done
}


sensor_test()
{
	println "start getting sensor data"
	sleep 1
	./mmc/utils/detect_acclerometer
	sleep 1
	./mmc/utils/detect_gyrometer
	sleep 1
	./mmc/utils/detect_mpl3115
	sleep 1
	./mmc/utils/mpl3115_temperature << end
1
end

}

sensor_loop()
{
	while true
	do
		sensor_test
		wait
	done
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
	while true
	do
		wpa_cli scan
		log_to_std
		wpa_cli scan_result
		log_to_file
		wait
		sleep 5

		wifi_connect
		if [ 6 = $? ] ; then
			break;
		fi
	done
}

battery_test()
{
	println "start getting battery status"
	./mmc/utils/bc3770 CHRG_GET_BC3770_INTMSK1
	sleep 1
	./mmc/utils/bc3770 CHRG_SET_BC3770_INTMSK1 0xff
	sleep 1
	./mmc/utils/bc3770 CHRG_GET_BC3770_INTMSK1
	sleep 1
}

battery_loop()
{
	while true
	do 
		battery_test
		wait
	done
}

start_test()
{
	log_to_file
	println ¡°start lcd display¡±
	lcd_test
	println ¡°start audio play¡±
	audio_loop &
	println ¡°start sensor read¡±
	sensor_loop &
	println ¡°start battery status¡±
	battery_loop &
	println ¡°start wifi scan¡±
	wifi_test
	wifi_loop &
}

goto_workspace
start_test

