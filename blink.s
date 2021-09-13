@ Blinks the LED on pin 21 on Raspberry Pi 4
@ Edited for Raspberry Pi 4 2021-09-13 Bicer
@ Orginal version 2017-09-30 Bob Plantz =https://bob.cs.sonoma.edu/IntroCompOrg-RPi/exercises-34.html
        .cpu    cortex-a72
        .fpu    neon-fp-armv8
        .syntax unified         @ modern syntax
        .equ    PIN,21           @ 1 bit for pin
        .equ    PINS_IN_REG,32
        .equ    GPSET0,0x1c     @ set register offset
        .equ    PIN_FIELD,0b111 @ 3 bits
        .equ    GPCLR0,0x28     @ clear register offset
        .equ    PROT_RDWR,0x3   @PROT_READ(0x1)|PROT_WRITE(0x2)
        .equ    BLOCK_SIZE,4096  @ Raspbian memory page
        .equ    OUTPUT,1        @ use pin for ouput
        .equ    ONE_SEC,1       @ sleep one second
        .equ    mem_fd_open,3 
        .equ    PIN21,21        @ pin set bit
        .equ    FILE_DESCRP_ARG,0   @ file descriptor
        .equ    DEVICE_ARG,3    @ device address
@ The following are defined in /usr/include/asm-generic/mman-common.h:
        .equ    MAP_SHARED,1 @ share changes
@ Constant program data
        .section .rodata
device:
        .asciz  "/dev/gpiomem"
@ The program
        .text
        .global main
        .global gpioPinClr
        .global gpioPinSet
        
main:
@ Open /dev/gpiomem for read/write and syncing        
        ldr     r1, O_RDWR_O_SYNC    @ flags for accessing device
        ldr     r0, mem_fd      @ address of /dev/gpiomem
        bl      open     
        mov     r4, r0          @ use r4 for file descriptor
@ Map the GPIO registers to a main memory location so we can access them
        str     r4, [sp, FILE_DESCRP_ARG] @ /dev/gpiomem file descriptor
        mov     r1, BLOCK_SIZE  @ get 1 page of memory
        mov     r2, PROT_RDWR   @ read/write this memory
        mov     r3, MAP_SHARED  @ share with other processes
        mov     r0, mem_fd_open @ address of /dev/gpiomem
        ldr     r0, GPIO_BASE   @ address of GPIO
        str     r0, [sp, DEVICE_ARG]      @ location of GPIO
        bl      mmap              
        mov     r5, r0          @ use r5 for programming memory address
        mov     r1, PIN21       @ pin to blink
        mov     r2, OUTPUT      @ it's an output     
    @ Set up the GPIO pin funtion register in programming memory
        add     r0, r10, r0     @ GPFSELn address
        mov     r3, PIN_FIELD   @ gpio pin field
        mov     r3, PINS_IN_REG @ divisor
@ All OK, blink the LED 

loop:
        mov     r0, r5          @ GPIO programming memory
        mov     r1, PIN21
        add     r8, r0, GPSET0  @ pointer to GPSET regs.
        mov     r9, r1          @ save pin number        
        udiv    r0, r9, r3      @ GPSET number
        add     r0, r0, r8      @ address of GPSETn
    @ Set up the GPIO pin funtion register in programming memory
        mov     r3, PIN         @ one pin
        lsl     r3, r3, r1      @ shift to pin position
        orr     r2, r2, r3      @ set bit
        str     r2, [r0]        @ update register
        mov     r0, ONE_SEC     @ wait a second
        bl      sleep
        mov     r0, r5
        mov     r1, PIN21
        add     r8, r0, GPCLR0  @ pointer to GPSET regs.
        mov     r9, r1          @ save pin number      
        udiv    r0, r9, r3      @ GPSET number
        add     r0, r0, r8      @ address of GPSETn
    @ Set up the GPIO pin funtion register in programming memory
        mov     r3, PIN         @ one pin
        lsl     r3, r3, r1      @ shift to pin position
        orr     r2, r2, r3      @ clear bit
        str     r2, [r0]        @ update register
        mov     r0, ONE_SEC     @ wait a second
        bl      sleep
        b       loop           

@ addresses of messages
GPIO_BASE:
        .word   0xfe200000 @GPIO Base address Raspberry pi 4
mem_fd:
        .word   device
O_RDWR_O_SYNC:
        .word   2|256       @ O_RDWR (2)|O_SYNC (256). 
