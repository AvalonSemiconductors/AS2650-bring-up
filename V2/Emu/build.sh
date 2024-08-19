#!/bin/bash

set - e

TRACE_FLAGS="--trace-depth 6 --trace -DTRACE_ON -CFLAGS '-DTRACE_ON'"
verilator -DBENCH -Wno-fatal --timing --top-module tb -cc -exe ${TRACE_FLAGS} bench.cpp tb.v spiflash.v sram_model.v AS2650/defines.v AS2650/as2650.v AS2650/avali_logo.v AS2650/boot_rom.v AS2650/gf180_ram_512x8_wrapper.v AS2650/user_project_wrapper.v AS2650/wrapped_as2650.v AS2650/SID/tt_um_rejunity_sn76489.v AS2650/SID/spi_dac_i.v AS2650/SID/SID_top.v AS2650/SID/SID_filter.v AS2650/SID/SID_channels.v AS2650/IO_Block/uart.v AS2650/IO_Block/timers.v AS2650/IO_Block/spi.v AS2650/IO_Block/serial_ports.v AS2650/IO_Block/ram_controller.v AS2650/IO_Block/gpios.v
cd obj_dir
make -f Vtb.mk
cd ..
