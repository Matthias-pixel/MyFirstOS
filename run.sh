clear;
set -e
mkdir -p build
nasm "src/boot.asm" -f bin -o "build/boot.bin"
nasm "src/kernel_entry.asm" -f elf -o "build/kernel_entry.o"
#i386-elf-gcc -ffreestanding -m32 -g -c "src/stdio.c" -o "build/stdio.o"
i386-elf-gcc -ffreestanding -m32 -O2 -g -c "src/kernel.c" -o "build/kernel.o"

nasm "src/zeroes.asm" -f bin -o "build/zeroes.bin"
i386-elf-ld -o "build/full_kernel.bin" -Ttext 0x1000 "build/kernel_entry.o" "build/kernel.o" --oformat binary
cat "build/boot.bin" "build/full_kernel.bin" "build/zeroes.bin"  > "build/OS.bin"
qemu-system-x86_64 -drive format=raw,file="build/OS.bin",index=0,if=floppy,  -m 128M