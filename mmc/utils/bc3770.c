
#include <termios.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <string.h>
#include "../drivers/misc/bc3770.h"


#define TOTAL_COMMAND 28


unsigned char *cmdlist[TOTAL_COMMAND]={
"CHRG_GET_BC3770_INT1",
"CHRG_GET_BC3770_INT2",
"CHRG_GET_BC3770_INT3",
"CHRG_GET_BC3770_INTMSK1",
"CHRG_GET_BC3770_INTMSK2",
"CHRG_GET_BC3770_INTMSK3",
"CHRG_GET_BC3770_STATUS",
"CHRG_GET_BC3770_CTRL",
"CHRG_GET_BC3770_VBUSCTRL",
"CHRG_GET_BC3770_CHGCTRL1",
"CHRG_GET_BC3770_CHGCTRL2",
"CHRG_GET_BC3770_CHGCTRL3",
"CHRG_GET_BC3770_CHGCTRL4",
"CHRG_GET_BC3770_CHGCTRL5",
"CHRG_SET_BC3770_INTMSK1",
"CHRG_SET_BC3770_INTMSK2",
"CHRG_SET_BC3770_INTMSK3",
"CHRG_SET_BC3770_CTRL",
"CHRG_SET_BC3770_VBUSCTRL",
"CHRG_SET_BC3770_CHGCTRL1",
"CHRG_SET_BC3770_CHGCTRL2",
"CHRG_SET_BC3770_CHGCTRL3",
"CHRG_SET_BC3770_CHGCTRL4",
"CHRG_SET_BC3770_CHGCTRL5",
"CHRG_SET_BC3770_CHARGE_EN",
"CHRG_GET_BC3770_CHARGE_EN",
"CHRG_SET_BC3770_SHDN",
"CHRG_GET_BC3770_SHDN",

};

void show_help(void)
{
	int count;
	printf("No arguments in GET commands\n\n");
	for(count=0;count<TOTAL_COMMAND;count++)
		printf("\t%s\n",cmdlist[count]);
}
unsigned int get_cmd(unsigned char *str)
{
        int count;
        for(count=0;count<TOTAL_COMMAND;count++)
                if(strcmp(str,cmdlist[count])==0)
			break;
	switch(count)
	{
		case 0: return CHRG_GET_BC3770_INT1; break;
		case 1: return CHRG_GET_BC3770_INT2; break;
		case 2: return CHRG_GET_BC3770_INT3; break;
		case 3: return CHRG_GET_BC3770_INTMSK1; break;
		case 4: return CHRG_GET_BC3770_INTMSK2; break;
		case 5: return CHRG_GET_BC3770_INTMSK3; break;
		case 6: return CHRG_GET_BC3770_STATUS; break;
		case 7: return CHRG_GET_BC3770_CTRL; break;
		case 8: return CHRG_GET_BC3770_VBUSCTRL; break;
		case 9: return CHRG_GET_BC3770_CHGCTRL1; break;
		case 10: return CHRG_GET_BC3770_CHGCTRL2; break;
		case 11: return CHRG_GET_BC3770_CHGCTRL3; break;
		case 12: return CHRG_GET_BC3770_CHGCTRL4; break;
		case 13: return CHRG_GET_BC3770_CHGCTRL5; break;
		case 14: return CHRG_SET_BC3770_INTMSK1; break;
		case 15: return CHRG_SET_BC3770_INTMSK2; break;
		case 16: return CHRG_SET_BC3770_INTMSK3; break;
		case 17: return CHRG_SET_BC3770_CTRL; break;
		case 18: return CHRG_SET_BC3770_VBUSCTRL; break;
		case 19: return CHRG_SET_BC3770_CHGCTRL1; break;
		case 20: return CHRG_SET_BC3770_CHGCTRL2; break;
		case 21: return CHRG_SET_BC3770_CHGCTRL3; break;
		case 22: return CHRG_SET_BC3770_CHGCTRL4; break;
		case 23: return CHRG_SET_BC3770_CHGCTRL5; break;
		case 24: return CHRG_SET_BC3770_CHARGE_EN; break;
		case 25: return CHRG_GET_BC3770_CHARGE_EN; break;
		case 26: return CHRG_SET_BC3770_SHDN; break;
		case 27: return CHRG_GET_BC3770_SHDN; break;

	}


	return -1;
}


int main(int argc, char *argv[])
{
	int fd, ret;
	unsigned char name[50],val,hex_str[10];
	unsigned int cmd,hex;

	if(argc == 1)
	{
		show_help();
		return 0;	//exit the application
	}
	else if(argc == 2)
	{
		cmd = get_cmd(argv[1]);
		if(cmd == -1)
		{
			printf("Command not Valid \n");
			return 0;
		}
		fd = open("/dev/FreescaleBatteryCharger",O_RDWR);
		if(fd == -1)
		{
                        printf("Unable to open /dev/FreescaleBatteryCharger \n");
                        return 0;
		}

		ret = ioctl(fd, cmd, &val);
		printf("%s = 0x%x\n",argv[1],val);
		close(fd);
	}
	else if(argc > 2)
	{
		printf ("argv[2]=%s\n",argv[2]);
		memset(hex_str,0,sizeof(hex_str));
		strncpy(hex_str,argv[2]+2,2);
		printf ("hex_str=%s hex=%x\n",hex_str,atoi(hex_str));
		sscanf(hex_str,"%x",&hex);
//		hex=strtol(hex_str,NULL,0);
		cmd = get_cmd(argv[1]);
		if(cmd == -1)
		{
			printf("Command not Valid \n");
			return 0;
		}
		fd = open("/dev/FreescaleBatteryCharger",O_RDWR);
		if(fd == -1)
		{
                        printf("Unable to open /dev/FreescaleBatteryCharger \n");
                        return 0;
		}

		val=(unsigned char)hex;
		ret = ioctl(fd, cmd, &val);
		printf("val=%x\n",val);
		close(fd);

	}



#if 0
	fd = open("/dev/NxpBatteryCharger",O_RDWR);
	memset(name,0,sizeof(name));



	ret = ioctl(fd, CHRG_GET_MODEL_NAME, name);
	printf("ret = %d\n",ret);
	if ( ret < 0)
		printf("CHRG_GET_MODEL_NAME failed: %s\n",strerror(errno));
	else 
		printf("%s\n",name);





	ioctl(fd,CHRG_GET_BC3770_INT1,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_INT2,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_INT3,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_INTMSK1,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_INTMSK2,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_INTMSK3,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_STATUS,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_CTRL,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_VBUSCTRL,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_CHGCTRL1,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_CHGCTRL2,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_CHGCTRL3,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_CHGCTRL4,&val);
	printf("val=0x%x\n",val);

	ioctl(fd,CHRG_GET_BC3770_CHGCTRL5,&val);
	printf("val=0x%x\n",val);

	close(fd);
#endif
	return 0;
}


/*
#define CHRG_IOCTL_BASE 'B'
#define CHRG_GET_MODEL_NAME             _IOR(CHRG_IOCTL_BASE, 0, char *)
#define CHRG_GET_BC3770_INT1            _IOR(CHRG_IOCTL_BASE, 1, unsigned char)
#define CHRG_GET_BC3770_INT2            _IOR(CHRG_IOCTL_BASE, 2, unsigned char)
#define CHRG_GET_BC3770_INT3            _IOR(CHRG_IOCTL_BASE, 3, unsigned char)
#define CHRG_GET_BC3770_INTMSK1         _IOR(CHRG_IOCTL_BASE, 4, unsigned char)
#define CHRG_GET_BC3770_INTMSK2         _IOR(CHRG_IOCTL_BASE, 5, unsigned char)
#define CHRG_GET_BC3770_INTMSK3         _IOR(CHRG_IOCTL_BASE, 6, unsigned char)
#define CHRG_GET_BC3770_STATUS          _IOR(CHRG_IOCTL_BASE, 7, unsigned char)
#define CHRG_GET_BC3770_CTRL            _IOR(CHRG_IOCTL_BASE, 8, unsigned char)
#define CHRG_GET_BC3770_VBUSCTRL        _IOR(CHRG_IOCTL_BASE, 9, unsigned char)
#define CHRG_GET_BC3770_CHGCTRL1        _IOR(CHRG_IOCTL_BASE, 10, unsigned char)
#define CHRG_GET_BC3770_CHGCTRL2        _IOR(CHRG_IOCTL_BASE, 11, unsigned char)
#define CHRG_GET_BC3770_CHGCTRL3        _IOR(CHRG_IOCTL_BASE, 12, unsigned char)
#define CHRG_GET_BC3770_CHGCTRL4        _IOR(CHRG_IOCTL_BASE, 13, unsigned char)
#define CHRG_GET_BC3770_CHGCTRL5        _IOR(CHRG_IOCTL_BASE, 14, unsigned char)
#define CHRG_SET_BC3770_INT1            _IOW(CHRG_IOCTL_BASE, 1, unsigned char)
#define CHRG_SET_BC3770_INT2            _IOW(CHRG_IOCTL_BASE, 2, unsigned char)
#define CHRG_SET_BC3770_INT3            _IOW(CHRG_IOCTL_BASE, 3, unsigned char)
#define CHRG_SET_BC3770_INTMSK1         _IOW(CHRG_IOCTL_BASE, 4, unsigned char)
#define CHRG_SET_BC3770_INTMSK2         _IOW(CHRG_IOCTL_BASE, 5, unsigned char)
#define CHRG_SET_BC3770_INTMSK3         _IOW(CHRG_IOCTL_BASE, 6, unsigned char)
#define CHRG_SET_BC3770_STATUS          _IOW(CHRG_IOCTL_BASE, 7, unsigned char)
#define CHRG_SET_BC3770_CTRL            _IOW(CHRG_IOCTL_BASE, 8, unsigned char)
#define CHRG_SET_BC3770_VBUSCTRL        _IOW(CHRG_IOCTL_BASE, 9, unsigned char)
#define CHRG_SET_BC3770_CHGCTRL1        _IOW(CHRG_IOCTL_BASE, 10, unsigned char)
#define CHRG_SET_BC3770_CHGCTRL2        _IOW(CHRG_IOCTL_BASE, 11, unsigned char)
#define CHRG_SET_BC3770_CHGCTRL3        _IOW(CHRG_IOCTL_BASE, 12, unsigned char)
#define CHRG_SET_BC3770_CHGCTRL4        _IOW(CHRG_IOCTL_BASE, 13, unsigned char)
#define CHRG_SET_BC3770_CHGCTRL5        _IOW(CHRG_IOCTL_BASE, 14, unsigned char)
 */

