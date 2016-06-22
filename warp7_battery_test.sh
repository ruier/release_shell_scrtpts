#!/bin/bash

battery_test()
{
	./mmc/utils/bc3770 CHRG_GET_BC3770_INTMSK1

	if [ $? -eq 0 ]; then
        echo
	else
        return 1
	fi

	./mmc/utils/bc3770 CHRG_SET_BC3770_INTMSK1 0xff


	if [ $? -eq 0 ]; then
        echo  
	else
        return 1
	fi

	./mmc/utils/bc3770 CHRG_GET_BC3770_INTMSK1

	if [ $? -eq 0 ]; then
        echo  
	else
        return 1
	fi
	return 0
}

battery_test

return_code=$?

if [ $return_code == 1 ]; then
         echo -e "\n\033[31mFAIL\033[0m\n"
         exit 1

elif [ $return_code == 0 ] ; then
        echo -e "\033[32mPASS\n\033[0m"
        exit 0
fi