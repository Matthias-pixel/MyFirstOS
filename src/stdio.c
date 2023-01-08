#ifndef MOST_STDIO
#define MOST_STDIO

#include "types.c"
#include "graphics.c"
int cursorX = 0;
void putsColor(char* str, unsigned char color) {
    int i = 0;
    do {
        if(*str == '\r') {
            i -= (cursorX*2+i)%(VGA_WIDTH*2);
            i--;
        } else if(*str == '\n') {
            i += VGA_WIDTH*2;
            i -= (cursorX*2+i)%(VGA_WIDTH*2);
            i--;
        } else {
            *(char*)(0xb8000+i+cursorX*2) = *str;
            *(char*)(0xb8001+i+cursorX*2) = color;
        }
        str++;
        i+=2;
    } while(*str != '\0');
    cursorX += i/2;
    update_cursor_position(cursorX%VGA_WIDTH, cursorX/VGA_WIDTH);
}
void puts(char* str) {
    putsColor(str, 0x0f);
}
int genVgaColorCode(unsigned char forecolor, unsigned char backcolor) {
    return (backcolor << 4) | (forecolor & 0x0F);
}
void intToString(int n, char* str, uint8_t strlen) {
    uint8_t digits[strlen];
    int i = 0;
    while(n != 0 && i < strlen-1) {
        digits[i] = n%10;
        n = n/10;
        i++;
    }
    if(i == 0) {
        *str = '0';
        str++;
        *str = '\0';
        return;
    }
    for(i--; i >= 0; i--) {
        *str = '0'+digits[i];
        str++;
    }
    *str = '\0';
}
void strcat(char* dst, char* src) {
    int i = 0;
    while(*dst != '\0') {
        dst++;
    }
    do {
        *dst = *src;
        src++;
    } while(*src != '\0');
}

#endif