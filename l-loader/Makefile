CROSS_COMPILE=arm-linux-gnueabihf-
CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy
BL1=bl1.bin

all: l-loader.bin ptable.img

l-loader.bin: start.o debug.o $(BL1)
	$(LD) -Bstatic -Tl-loader.lds -Ttext 0x7fe00800 start.o debug.o -o loader.elf
	$(OBJCOPY) -O binary loader.elf temp
	python gen_loader.py -o $@ --img_loader=temp --img_bl1=$(BL1)
#	rm -f temp loader
	rm -f temp

ptable.img:
	sh generate_ptable.sh
	python gen_loader.py -o $@ --img_prm_ptable=prm_ptable.img --img_sec_ptable=sec_ptable.img

clean:
	rm -f *.o l-loader.bin ptable.img prm_ptable.img sec_ptable.img
