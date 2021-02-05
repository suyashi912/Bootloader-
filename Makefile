# Name : Suyashi Singhal 
# Roll no: 2019478

compile:	bootloader_2019478.asm 
	nasm -f bin bootloader_2019478.asm -o bootloader_2019478.bin 

run: 		bootloader_2019478.bin
	qemu-system-x86_64 -fda bootloader_2019478.bin 
