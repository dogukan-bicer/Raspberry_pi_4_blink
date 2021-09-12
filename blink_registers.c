//  How to access GPIO registers from C-code on the Raspberry-Pi 4
//  Orginal version===>https://elinux.org/RPi_GPIO_Code_Samples#Direct_register_access
#define GPIO_BASE  0xfe200000 // BCM2711 GPIO Base 
#define BLOCK_SIZE 4096

#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

int  mem_fd;
void *gpio_map;

// I/O access
volatile unsigned *gpio;
#define OUT_GPIO(g) *(gpio+((g)/10)) |=  (1<<(((g)%10)*3))
#define GPIO_SET *(gpio+7)  // sets   bits which are 1 ignores bits which are 0
#define GPIO_CLR *(gpio+10) // clears bits which are 1 ignores bits which are 0

int main(int argc, char **argv)
{
  // Setup gpi pointer for direct register access
     /* open /dev/mem */
   mem_fd = open("/dev/mem", O_RDWR|O_SYNC);  
   /* mmap GPIO */
   gpio_map = mmap(
      NULL,             //Any adddress in our space will do
      BLOCK_SIZE,       //Map length
      PROT_READ|PROT_WRITE,// Enable reading & writting to mapped memory
      MAP_SHARED,       //Shared with other processes
      mem_fd,           //File to map
      GPIO_BASE         //Offset to GPIO peripheral
   );
   // Always use volatile pointer!
   gpio = (volatile unsigned *)gpio_map;
  // Set GPIO pins 21 to output
   OUT_GPIO(21);
  while(1){
  // Pin 21 blinks every 1 second
       GPIO_SET = 1<<21;
       sleep(1);
       GPIO_CLR = 1<<21;
       sleep(1);
   }
} 
