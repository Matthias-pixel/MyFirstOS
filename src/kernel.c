#include "./stdio.c"
#include "./graphics.c"
extern void main() {
    setup_cursor();
    puts("Hello from C!\n");
    uint8_t x, y;
    get_cursor_position(&x, &y);
    puts("Cursor position: ");
    char xString[4];
    char yString[4];
    intToString(x, xString, 4);
    intToString(y, yString, 4);
    puts(xString);
    puts(", ");
    puts(yString);
    puts("\n");
    puts("Second string!\n");
    for(;;){}
    return;
}