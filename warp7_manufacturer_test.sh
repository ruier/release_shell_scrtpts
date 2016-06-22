#!/bin/bash

version="1.0"
board="WaRP 7"
items_num=0
list_file="./item_list.txt"
declare -a test_item_array

bootid=`cat /proc/sys/kernel/random/boot_id`
WORK_PATH=/root
mmc=mmcblk2p1

goto_workspace()
{
	cd $WORK_PATH
}

check_device()
{
	ls /dev/$1 
	if [ $? -eq 0 ]
		then 
		return 0

	else
		echo "$1 not found!"
		return 1
	fi
}

mount_mmc()
{
	mkdir -p $mmc
	check_device mmcblk2p1
	mount /dev/mmcblk2p1 $mmc
}

umount_mmc()
{
	flag=`mount | grep $mmc`

	if [ x"$flag" == x"" ]; then
		echo $mmc not mounted
		return 0
	else
		umount $mmc
		return $?
	fi
}

read_list()
{
    n=0
    while read line
    do
        test_item_array[n++]="$line"
        echo ${test_item_array[n-1]}
    done < $list_file
    items_num=${#test_item_array[@]}
}

inital_test() {
	echo "------------------------------------------"
	echo "------------------------------------------"
    echo $board Test Start, version=$version
    echo $items_num items will be executed
    echo "------------------------------------------"
    echo -e "\033[33m--Please press any key to start manufacturer test--\033[0m"
    echo -e "\033[33m-----------Or do nothing for auto test------------\033[0m"
}

handle_test_result() {
    echo $1 $2 $3
    # do log here if needed
}

main_test() {
    for((i=0;i<$items_num;i++)) do {
	first_flag=0
        test_item=${test_item_array[$i]}
        echo $test_item
	result="${result}${test_item} "
        #result=`./$test_item`
        if [ -f $test_item ] 
        then 
			./$test_item
        	return_code=$?
        else
        	return_code=1
        fi

        if [ $return_code == 1 ]; then
	    echo -e "\n\033[31mFAIL\033[0m\n"
	    result="$result \033[31mFAIL\033[0m \n"
	    first_flag=1
        fi
        #handle_test_result $return_code $result
	
	if [ $first_flag -eq 0 ] ; then
            read -t 1 cmd
            if [ "${cmd}" == "x" ] ; then
                if [ $first_flag -eq 0 ] ; then
		    result="$result \033[31mFAIL\033[0m \n"
		    first_flag=1
		    echo -e "\n\033[31mFAIL\033[0m\n"
	        fi
	        #echo -e "\033[31mFAIL\033[0m"
            fi
	fi
	if [ $first_flag -eq 0 ] ; then
	    result="$result \033[32mPASS\033[0m \n"
            echo -e "\033[32mPASS\n\033[0m"
	fi
    }
    done

    echo -e "\033[32m$board TEST COMPLETE!\n\033[0m"
    echo -e "$result"
    mount_mmc
    echo -e "$result" > $mmc/$bootid.txt
    umount_mmc
    exit 0
}

goto_workspace
read_list
inital_test

read -t 30 cmd
if [ ! $? -eq 0 ] ; then
	main_test
    exit 0
fi
main_test

exit 0
