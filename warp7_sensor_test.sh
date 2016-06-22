#!/bin/bash

sensor1=/sys/class/misc/FreescaleAccelerometer
sensor2=/sys/class/misc/FreescaleGyroscope
sensor3=/sys/class/misc/FreescaleMagnetometer

echo 1 > $sensor1/enable
echo 1 > $sensor2/enable
echo 1 > $sensor3/enable

sensor_test() {
	key=0
for inputX in /sys/class/input/input*
        do
                name=`cat $inputX/name`
                if [ x"$name" == x"$1" ]; then
                        key=1                        
                        break;    
                fi                
        done                  
if [ $key -eq 0 ] ; then
        echo gpio key not found
        echo -e "\n\033[31mFAIL\033[0m\n"
        exit 1                 
fi                             

if [ x"mpl3115" == x"$1" ]; then
	echo 1 > $inputX/enable
fi
             
eventX=`basename $inputX/event*`
hexdump -n 50 /dev/input/$eventX > /dev/null 
echo -ne "\033[32m$name $eventX got\033[0m"
return 0
}

sensor_test fxos8700

return_code=$?

if [ $return_code == 1 ]; then
         echo -e "\n\033[31mFAIL\033[0m\n"
         exit 1

elif [ $return_code == 0 ] ; then
        echo -e "\033[32mPASS\n\033[0m"
        exit 0
fi

sensor_test fxas2100x

return_code=$?

if [ $return_code == 1 ]; then
         echo -e "\n\033[31mFAIL\033[0m\n"
         exit 1

elif [ $return_code == 0 ] ; then
        echo -e "\033[32mPASS\n\033[0m"
        exit 0
fi

sensor_test mpl3115

return_code=$?

if [ $return_code == 1 ]; then
         echo -e "\n\033[31mFAIL\033[0m\n"
         exit 1

elif [ $return_code == 0 ] ; then
        echo -e "\033[32mPASS\n\033[0m"
        exit 0
fi

exit 0