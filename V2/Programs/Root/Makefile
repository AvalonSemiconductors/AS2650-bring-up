ASL_DIR = ../asl
ASL = $(ASL_DIR)/asl
P2BIN = $(ASL_DIR)/p2bin
ARCH = AS2650-2

PROJECTS = root.bin snake.bin ba.bin frames.bin

%.p: %.asm
	$(ASL) -cpu $(ARCH) $<

%.bin: %.p
	$(P2BIN) $<

badapple:
	java FramesToROM.java

combined: $(PROJECTS)
	./a.out $^

flash: combined
	sudo flashrom --programmer ch341a_spi --write combined.bin

clean:
	rm -rf root.bin snake.bin ba.bin *.p

all: clean combined

.PHONY: all
