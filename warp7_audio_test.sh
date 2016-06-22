#!/bin/bash

if [ ! -e /dev/snd/pcmC0D0p ] ; 
	then exit 1 ; 
fi

if [ ! -e /dev/snd/pcmC0D0c ] ; 
	then exit 1 ; 
fi

arecord -t wav -c 1 -r 44100 -f S16_LE -v /mnt/k > /dev/null &
pid_arecord=$!
#echo $pid_arecord
sleep 5
kill -9 $pid_arecord 
sleep 1
#echo Play
aplay -t wav -c 2 -r 44100 -f S16_LE -v /mnt/k > /dev/null
if [ $? -eq 1 ] ; then 
	echo -ne "\033[31m0\033[0m"
	exit 1
fi

if [ -f /mnt/k ] ; then
	rm /mnt/k
fi
 
echo -e "\033[33m-- Audio play with sound?--\033[0m"
echo -e "\033[33m--(Y/N)?--\033[0m"

read var

if [ "$var" == "Y" ] || [ "$var" == "y" ]; then 
	echo -e "\033[32mPASS\n\033[0m"
	exit 0
else
	echo -e "\n\033[31mFAIL\033[0m\n"
	exit 1
fi
