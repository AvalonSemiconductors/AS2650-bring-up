# AS2650 bring-up
Hardware and Software used during bring-up of the GFMPW-0 AS2650.

## Repository Contents

`HW` - PCB design for the custom bring-up board with 8KiB of SRAM

`GAL` - AND term listing for the GAL device on the PCB - Can be assembled using [galette](https://github.com/simon-frankau/galette).

`Firmware` - Management Controller Firmware for the PCB - Must be used together with the headers and utils from [caravel_board](https://github.com/efabless/caravel_board/tree/main/firmware/gf180).

`Programs` - Programs written in AS2650 assembly - contains its own README.

`Bugs` - Contains a README documenting all silicon bugs, their severity, and possible workarounds.
