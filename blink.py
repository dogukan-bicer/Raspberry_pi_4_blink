from gpiozero import LED
from time import sleep

led = LED(16)

while True:
    led.on()
    sleep(0.1)#100 ms blink
    led.off()
    sleep(0.1)
    
