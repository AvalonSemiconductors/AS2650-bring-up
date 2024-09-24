ASL_DIR = ../asl
ASL = $(ASL_DIR)/asl
P2BIN = $(ASL_DIR)/p2bin
ARCH = AS2650-2

PROJECT = hellorld

%.p: %.asm
	$(ASL) -cpu $(ARCH) $<

%.bin: %.p
	$(P2BIN) $<

$(PROJECT): $(PROJECT).bin
	../a.out -i $(PROJECT).bin -o $(PROJECT)_header.bin

flash: $(PROJECT)
	sudo flashrom --programmer ch341a_spi --write $(PROJECT)_header.bin

clean:
	rm -rf *.bin *.p

all: clean $(PROJECT)

.PHONY: all
