clear;
set -e;

gcc -o fat fat.c;
dd if="/dev/zero" of="example_fs.img" bs=512 count=2880;
mkfs.fat -F 12 -n "EXAMPLE FS " "example_fs.img";
mcopy -i "example_fs.img" "myFile.txt" "::myFile.txt";