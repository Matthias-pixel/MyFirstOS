#ifndef MOST_IO
#define MOST_IO

static __inline void outb (unsigned short int __port, unsigned char __value) {
  __asm__ __volatile__ ("outb %b0,%w1": :"a" (__value), "Nd" (__port));
}
static __inline unsigned char inb (unsigned short int __port) {
  unsigned char _v;
  __asm__ __volatile__ ("inb %w1,%0":"=a" (_v):"Nd" (__port));
  return _v;
}

#endif