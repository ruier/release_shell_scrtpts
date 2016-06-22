echo -e "\033[33m--Can you read/write the NFC tag?--\033[0m"
echo -e "\033[33m--(Y/N)?--\033[0m"

read var

if [ x"$var" == x"Y" ] || [ x"$var" == x"y" ]; then
	echo -e "\033[32mPASS\n\033[0m"
	exit 0
else
	echo -e "\n\033[31mFAIL\033[0m\n"
	exit 1
fi