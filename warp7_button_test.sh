#!/bin/bash

key=0

for inputX in /sys/class/input/input*
        do
                name=`cat $inputX/name`
                if [ x"$name" == x"gpio-keys" ]; then
                        key=1                        
                        break;    
                fi                
        done                  
if [ $key -eq 0 ] ; then
        echo gpio key not found
        exit 1                 
fi                             
              
eventX=`basename $inputX/event*`

echo -e "\033[33m--Please press the buttom on board--\033[0m"

hexdump -n 50 /dev/input/$eventX > /dev/null 
return_code=$?

if [ $return_code == 1 ]; then
         echo -e "\n\033[31mFAIL\033[0m\n"
         exit 1

elif [ $return_code == 0 ] ; then
        echo -e "\033[32mPASS\n\033[0m"
        exit 0
fi