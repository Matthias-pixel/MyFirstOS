clear;
set -e;
mkdir -p build;

nasm "src/bootloader/stage1/boot.asm" -f bin -o "build/stage1.bin";
nasm "src/bootloader/stage2/main.asm" -f bin -o "build/stage2.bin";
nasm "src/kernel/main.asm" -f bin -o "build/kernel.bin";

dd if="/dev/zero" of="build/main_floppy.img" bs=512 count=2880;
mkfs.fat -F 12 -n "MY FIRST OS" "build/main_floppy.img";
dd if="build/stage1.bin" of="build/main_floppy.img" conv=notrunc;
mcopy -i "build/main_floppy.img" "build/kernel.bin" "::kernel.bin";
mcopy -i "build/main_floppy.img" "build/stage2.bin" "::stage2.bin";