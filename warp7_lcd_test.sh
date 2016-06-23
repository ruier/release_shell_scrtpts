#!/bin/bash

if [ ! -e /dev/fb0 ] ; then 
	echo -e "\n\033[31mFAIL\033[0m\n"
	exit 1 ; 
fi

fbset -yres 319
./mmc/fb-test 

echo -e "\033[33m--Do you see the color on the screen?--\033[0m"
echo -e "\033[33m--(Y/N)?--\033[0m"

read var

if [ "$var" == "Y" ] || [ "$var" == "y" ]; then 
	echo -e "\033[32mPASS\n\033[0m"
	exit 0
else
	echo -e "\n\033[31mFAIL\033[0m\n"
	exit 1
fi