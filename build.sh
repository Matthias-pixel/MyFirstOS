clear;
set -e;
mkdir -p build;

nasm "src/bootloader/boot.asm" -f bin -o "build/bootloader.bin";
nasm "src/kernel/main.asm" -f bin -o "build/kernel.bin";

dd if="/dev/zero" of="build/main_floppy.img" bs=512 count=2880;
mkfs.fat -F 12 -n "MYFIRSTOS" "build/main_floppy.img";
dd if="build/bootloader.bin" of="build/main_floppy.img" conv=notrunc;
mcopy -i "build/main_floppy.img" "build/kernel.bin" "::kernel.bin";