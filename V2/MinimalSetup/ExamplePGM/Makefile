ASL_DIR = ../asl-avalonsemi
ASL = $(ASL_DIR)/asl
P2BIN = $(ASL_DIR)/p2bin
ARCH = AS2650-2

PROJECT = example

%.p: %.asm
	$(ASL) -cpu $(ARCH) $<

%.bin: %.p
	$(P2BIN) $<

$(PROJECT): $(PROJECT).bin utils
	./a.out -i $(PROJECT).bin -o $(PROJECT)_header.bin

utils:
	gcc ../../Utils/append_header.c

flash: $(PROJECT)
	sudo flashrom --programmer ch341a_spi --write $(PROJECT)_header.bin

flash_fixed: $(PROJECT)
	sudo flashrom --programmer ch341a_spi --chip "W25Q32BV/W25Q32CV/W25Q32DV" --write $(PROJECT)_header.bin

clean:
	rm -rf *.bin *.p

all: clean $(PROJECT)

.PHONY: all
