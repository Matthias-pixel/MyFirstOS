#ifndef MOST_GRAPHICS
#define MOST_GRAPHICS

#include "io.c"
#include "types.c"
#define VGA_WIDTH 80

void enable_cursor(uint8_t cursor_start, uint8_t cursor_end) {
	outb(0x3D4, 0x0A);
	outb(0x3D5, (inb(0x3D5) & 0xC0) | cursor_start);
	outb(0x3D4, 0x0B);
	outb(0x3D5, (inb(0x3D5) & 0xE0) | cursor_end);
}
void disable_cursor(uint8_t cursor_start, uint8_t cursor_end) {
	outb(0x3D4, 0x0A);
	outb(0x3D5, 0x20);
}
void update_cursor_position(int x, int y) {
	uint16_t pos = y * VGA_WIDTH + x;
	outb(0x3D4, 0x0F);
	outb(0x3D5, (uint8_t) (pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (uint8_t) ((pos >> 8) & 0xFF));
}
void get_cursor_position(uint8_t* x, uint8_t* y) {
    outb(0x3D4, 0x0F);
    *x = inb(0x3D5);
    outb(0x3D4, 0x0E);
    *y = inb(0x3D5);
}
void setup_cursor() {
    enable_cursor(0, 15);
	update_cursor_position(0, 0);
}

#endif