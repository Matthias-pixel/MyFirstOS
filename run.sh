clear;
set -e
./build.sh
qemu-system-i386 -fda build/main_floppy.img