;; Main programm
mov cl, 'A'
loop:

    movzx eax, cl
    mov edx, 0
    mov ebx, 2          ;; Capitalize every 3rd letter
    div ebx             ;; divide eax/abx
    cmp edx, 0

    mov al, cl
    jne makeLowerCase
print:
    mov ah, 0x0e            ;; Setup Teletype mode
    int 0x10
    inc cl
    cmp cl, ('Z'+1)
    jb loop
jmp $                   ;; Jump to the current address - infinite loop

makeLowerCase:
    add al, 32
    jmp print

times 510-($-$$) db 0   ;; Fill the remaining space with zeros

;; Mark the disk as executable
db 0x55, 0xaa