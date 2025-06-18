
#TOOLCHAIN_PATH=/usr/bin/
TOOLCHAIN_PATH=/usr/bin/
#TOOLCHAIN_PATH=/opt/riscv32imc/bin/
# TOOLCHAIN_PATH=/ef/apps/bin/

# Set the prefix for `riscvXX-unknown-elf-*`
# On installations using `multilib`, this will be `riscv64` even for compiling to 32-bit targets
TOOLCHAIN_PREFIX=riscv64-unknown-elf
#TOOLCHAIN_PREFIX=riscv32

# ---- Test patterns for project raven ----

.SUFFIXES:

PATTERN = blink

hex:  ${PATTERN:=.hex}
bin:  ${PATTERN:=.bin}

%.elf: %.c ../../../caravel_board/firmware/gf180/sections.lds ../../../caravel_board/firmware/gf180/crt0_vex.S
	#$(TOOLCHAIN_PATH)riscv32-unknown-elf-gcc -O0 -march=rv32i -Wl,-Bstatic,-T,../sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ ../start.s ../print_io.c $<
	#$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-gcc -I../ -I../generated/ -O0 -mabi=ilp32 -march=rv32i -D__vexriscv__ -Wl,-Bstatic,-T,../sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ ../crt0_vex.S ../isr.c ../stub.c $<
	$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-gcc -I../../../caravel_board/firmware/gf180/ -I../../../caravel_board/firmware/gf180/generated/ -O0 -mabi=ilp32 -march=rv32i_zicsr -D__vexriscv__ -Wl,-Bstatic,-T,../../../caravel_board/firmware/gf180/sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ ../../../caravel_board/firmware/gf180/crt0_vex.S ../../../caravel_board/firmware/gf180/isr.c $<
	${TOOLCHAIN_PATH}$(TOOLCHAIN_PREFIX)-objdump -D blink.elf > blink.lst

%.hex: %.elf
	$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-objcopy -O verilog $< $@
	sed -ie 's/@1000/@0000/g' $@

%.bin: %.elf
	$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-objcopy -O binary $< $@

flash: blink.bin
	java ../../Utils/ExpandROM.java $@ 131072
	sudo flashrom --programmer ch341a_spi --write expanded.bin

flash_fixed: blink.bin
	java ../../Utils/ExpandROM.java $@ 4194304
	sudo flashrom --programmer ch341a_spi --chip "W25Q32BV/W25Q32CV/W25Q32DV" --write expanded.bin

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.hexe *.lst

.PHONY: clean hex bin all
