ASL_DIR = /run/media/tholin/8a6b8802-051e-45a8-8492-771202e4c08a/asl-avalonsemi/
ASL = $(ASL_DIR)/asl
P2BIN = $(ASL_DIR)/p2bin
ARCH = AS2650-2

PROJECT = vfd

%.p: %.asm
	$(ASL) -cpu $(ARCH) $<

%.bin: %.p
	$(P2BIN) $<

$(PROJECT): $(PROJECT).bin
	../a.out -i $(PROJECT).bin -o $(PROJECT)_header.bin

flash: $(PROJECT)
	sudo flashrom --programmer ch341a_spi --write $(PROJECT)_header.bin --chip "W25Q32BV/W25Q32CV/W25Q32DV"

clean:
	rm -rf *.bin *.p

all: clean $(PROJECT)

.PHONY: all
