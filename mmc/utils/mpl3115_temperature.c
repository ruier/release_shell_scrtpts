#include <stdio.h>
#include <stdint.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <string.h>

static int write_register(int file,unsigned char address,unsigned char reg,unsigned char data)
{

   unsigned char output_buffer[2];
   struct i2c_rdwr_ioctl_data packets;
   struct i2c_msg messages[1];

    messages[0].addr  = address;
    messages[0].flags = 0;
    messages[0].len   = sizeof(output_buffer);
    messages[0].buf   = output_buffer;

    output_buffer[0] = reg;
    output_buffer[1] = data;

    packets.msgs  = messages;
    packets.nmsgs = 1;

    if(ioctl(file, I2C_RDWR, &packets) < 0) {
        perror("Error sending data");
        return 1;
    }

    return 0;
}


static int read_register(int file, unsigned char address, unsigned char reg, unsigned char *data)
{
    unsigned char input_buffer, output_buffer;
    struct i2c_rdwr_ioctl_data packets;
    struct i2c_msg messages[2];


    output_buffer = reg;
    messages[0].addr  = address;
    messages[0].flags = 0;
    messages[0].len   = sizeof(output_buffer);
    messages[0].buf   = &output_buffer;

    messages[1].addr  = address;
    messages[1].flags = I2C_M_RD;
    messages[1].len   = sizeof(input_buffer);
    messages[1].buf   = &input_buffer;


    packets.msgs      = messages;
    packets.nmsgs     = 2;
    if(ioctl(file, I2C_RDWR, &packets) < 0) {
        perror("Error sending data");
        return 1;
    }
    *data = input_buffer;

    return 0;
}


int main() {
    int file, i;
    unsigned char data;
    int val1;
    int val2;
    int t_m;
    int choice;
    int DBG_ENABLE = 0;
    char string[200];

printf("Enable Debugging [1-Enable/0-Disable] :");
scanf("%d",&choice);

    if (choice == 1)
        DBG_ENABLE = 1;
    else if (choice == 0)
        DBG_ENABLE = 0;
    else
        {
            printf("Unknown choice \n Exiting... \n");
            exit(1);
        }

if ((file = open("/dev/i2c-3", O_RDWR)) < 0)
{
    perror("Error openning file!");
    exit(1);
  }

if(DBG_ENABLE == 0)
printf("Debugging Disabled \n");
else if(DBG_ENABLE == 1)
printf("Debugging Enabled \n");
else
printf("No idea");


//0x0C whoami verify
   if(read_register(file, 0x60, 0x0C, &data))
    exit(1);
   else
   {
    if(DBG_ENABLE == 1)
     { printf("GET:Register[0x%02X]: 0x%02X\n" , 12 , data);
     }
   }
//0x26 set ctrlreg1 ACTIVE
   if(read_register(file, 0x60, 0x26, &data))
      exit(1);
   else
   {
    if(DBG_ENABLE == 1)
     { printf("GET:Register[0x%02X]: 0x%02X\n" , 38 , data);
     }
   }


   if(write_register(file, 0x60, 0x26, 0x03))
     exit(1);
   else
     {
        if(read_register(file, 0x60, 0x26, &data))
           exit(1);
        else
       {
    if(DBG_ENABLE == 1)
        {  printf("SET/GET:Register[0x%02X]: 0x%02X\n" , 38 , data);
        }
       }

     }

int counter=0;
while(counter<5)
{
//read temperature MSB/LSB
   if(read_register(file, 0x60, 0x04, &data))
     exit(1);
/*   else*/
/*    { if(DBG_ENABLE == 1)  */
/*        {   printf("Register[0x%02X]: 0x%02X\n" , 4 , data);*/
/*        }*/
/*    }*/

        val2 = (int)data;
        if(DBG_ENABLE == 1) printf("val2: initial :%d:\n",val2);
        val2 <<=8;
        if(DBG_ENABLE == 1) printf("val2: shift :%d:\n",val2);


   if(read_register(file, 0x60, 0x05, &data))
    exit(1);
   else
   {
     if(DBG_ENABLE == 1)
     printf("Register[0x%02X]: 0x%02X\n" , 5 , data);
   }

    val2 = val2+ (int)data;

    if(DBG_ENABLE == 1)
    { printf("val2 :%d:\n",val2);
    }

    t_m = (val2 >> 8) & 0xff;

   printf("temperature :%d: \n",t_m);

  system(string);
   sleep(1);
	counter++;
}
    close(file);
    return 0;
}




