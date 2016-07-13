#!/bin/bash

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
hcitool scan

echo -e "\033[33m--Do you see the bluetooth device detected?--\033[0m"
echo -e "\033[33m--(Y/N)?--\033[0m"

read var

if [ "$var" == "Y" ] || [ "$var" == "y" ]; then
        echo -e "\033[32mPASS\n\033[0m"
        exit 0
else
        echo -e "\n\033[31mFAIL\033[0m\n"
        exit 1
fi
~        
