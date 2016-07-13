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

sensor_init()
{
sensor1=/sys/class/misc/FreescaleAccelerometer
sensor2=/sys/class/misc/FreescaleGyroscope
sensor3=/sys/class/misc/FreescaleMagnetometer

echo 1 > $sensor1/enable
echo 1 > $sensor2/enable
echo 1 > $sensor3/enable
}

wifi_test()
{
insmod /lib/modules/4.1.15-1.0.0+g54cf6a2/kernel/drivers/net/wireless/bcmdhd/bcmdhd.ko \
firmware_path=/lib/firmware/bcm/fw_bcmdhd.bin \
nvram_path=/lib/firmware/bcm/bcmdhd.cal 
}

wifi_connect()
{
wl down
wl mpc 0
wl phy_watchdog 0
wl glacial_timer 0x7fffffff
wl country ALL
wl band b
wl chanspec 7/20
wl up
wl phy_forcecal 1
wl scansuppress 1
wl phy_txpwrctrl 1
wl pkteng_start 00:11:22:33:44:55 rx
sleep 60
wl pkteng_stop rx
}

wifi_loop()
{
wifi_connect
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

bt_init() {
echo 145 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio145/direction
echo 0 > /sys/class/gpio/gpio145/value
sleep .500
echo 1 > /sys/class/gpio/gpio145/value
sleep 1
hciattach ttymxc2 bcm43xx 3000000 flow
sleep .100
hciconfig hci0 up
sleep .100
hciconfig -a
}

start_test()
{
	log_to_file
	println ¡°start lcd display¡±
	lcd_test
	println ¡°start audio play¡±
	audio_loop &
	println ¡°start sensor read¡±
	sensor_init
	println ¡°start battery status¡±
	battery_loop &
	println ¡°start wifi scan¡±
	wifi_test
	wifi_loop &
	bt_init
}

goto_workspace
start_test

