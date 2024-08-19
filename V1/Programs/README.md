# AS2650 Programs
This is a collection of programs meant to be able to run on the AS2650 bring-up PCB.
Also contains a modified version of my 2650 assembler with patches to handle the AS2650.

There are also scripts written in Java to convert the assembler outputs into formats required by the management controller firmware or bootloader.

`bootloader` is the Bootloader written into RAM by the management controller on power-up. It initializes all other hardware, and boots a program from a SPI ROM.
All the other programs only work properly in the context of the bootloader having initialized the UART hardware.

`Hellorld` - Tests the UART

`AddTest` - Used to track down a silicon bug to do with carry flag generation

All other programs are modifications from [S2650-tools](https://github.com/89Mods/S2650-tools/tree/main).
