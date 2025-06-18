# AS2650v2 minimal setup

Instructions for setting up a AS2650v2 on a breadboard and using it to blink an LED. Requires a AS2650v2 chip soldered to a [breakout board](https://github.com/AvalonSemiconductors/gfmpw-breakout/tree/main).

## First-time setup

The following steps only need to be done once. First, ensure that this repo has been cloned recursively and all submodules are there. Then, build the firmware in "CaravelFirmware" and flash it to the breakout using `make flash` in this directory. If you get an error during flash, try `make flash_fixed`. You may need to install the RISC-V toolchain for your distro.

To assembly any programs for the AS2650v2, my fork of ASL then needs to be installed: [AvalonSemiconductors/asl-avalonsemi](https://github.com/AvalonSemiconductors/asl-avalonsemi).
This is accomplished by cloning this repo inside the directory with this readme, such that the directory structure is `MinimalSetup/asl-avalonsemi/`, and then a system-wide install will not be required for the rest of this guide. Then doing `git checkout avalonsemi` in the cloned repo and `cp Makefile.def-samples/Makefile.def-x86_64-unknown-linux Makefile.def` then finally `make`.

The "KiCad" directory contains a KiCad schematic showing the required hardware setup. It requires another SPI flash IC which is later flashed with the firmware for the AS2650v2. If you obtained a CH341A to program the GFMPW breakout board, then that same programmer can be used to flash this chip as well.

## Running the example program

To assemble the example program, simply navigate to "ExamplePGM" and do `make`. If successful, running `make flash` or `make flash_fixed` can be used to flash the resulting file, and the prepared spiflash put back into the breadboard circuit.

Powering up the board should now cause the AS2650v2 to bootload from the spiflash and start running the example program. The program blinks the "flag" output, which is visible as one of the two LEDs on the breakout, and counts up on the PORTA pins. It also generates UART frames on PA1/TXD at a baudrate of 115200 if the chip is clocked at 50MHz.
