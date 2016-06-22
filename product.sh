#!/bin/sh

WORK_PATH=/root
mmc=mmcblk2p1
file=log_file.txt

disable_kernel_log_print()
{
	echo -1 > /proc/sys/kernel/printk
}

enable_kernel_log_print()
{
	echo 8 > /proc/sys/kernel/printk
}

log_to_file()
{
	
	exec 6>&2
	exec 7>&1
	exec 2>$file
	exec 1>$file
}

log_to_std()
{
	exec 2>&6 6>&-
	exec 1>&7 7>&-
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
		then println $1 found

	else
		println "$1 not found!"
		return
	fi
}

mount_mmc()
{
	mkdir $mmc
	check_device mmcblk2p1
	mount /dev/mmcblk2p1 $mmc
}

umount_mmc()
{
	umount $mmc
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
	aplay mmc/dang.wav
}

audio_loop()
{
	while true
	do
		audio_test
	done
}

sensor_test()
{
	./mmc/utils/detect_acclerometer
	./mmc/utils/detect_gyrometer
	./mmc/utils/detect_mpl3115
	./mmc/utils/mpl3115_temperature << end
1
end

}

sensor_loop()
{
	while true
	do
		sensor_test
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

battery_test()
{
	./mmc/utils/bc3770 CHRG_GET_BC3770_INTMSK1
	./mmc/utils/bc3770 CHRG_SET_BC3770_INTMSK1 0xff
	./mmc/utils/bc3770 CHRG_GET_BC3770_INTMSK1
}

usb_emmc_test()
{
	mount_mmc
	cp $file $mmc
	insmod modules/libcomposite.ko
	insmod modules/usb_f_mass_storage.ko
	insmod modules/g_mass_storage.ko file=/dev/mmcblk2p1 stall=0 removable=1,1	
}

battery_loop()
{
	while true
	do 
		battery_test
	done
}

start_prescan_test()
{
	lcd_test
	audio_loop &
	sensor_loop &
	battery_loop &
	wifi_test
}

start_product_test()
{
	case "$1" in 
	"lcd")
		lcd_test
	;;
	"audio")
		audio_test
	;;
	"sensor")
		sensor_test
	;;
	"battery")
		battery_test
	;;
	"wifi")
		wifi_test
	;;
	"usb")
		usb_emmc_test
	;;
	"emmc")
		usb_emmc_test
	;;
	esac
}

goto_workspace
while true
do 
	echo Select the device to test:
	read var
	log_to_file
	start_product_test $var
	log_to_std
done


