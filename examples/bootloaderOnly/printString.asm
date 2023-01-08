[org 0x7c00]
;; Main programm
mov ecx, hello_world_string
loop:
    push ecx
    call print_string
    pop ecx
    inc ecx
    cmp ecx, (hello_world_string+20)
    jb loop
jmp $

print_string:
print_string_loop:
    mov ah, 0x0e
    mov al, [ecx]
    cmp al, 0
    je print_string_exit
    int 0x10
    inc ecx
    jmp print_string_loop
print_string_exit:
    ret

hello_world_string:
    db "Was geht ab!", 13, 10, 0
times 510-($-$$) db 0   ;; Fill the remaining space with zeros

;; Mark the disk as executable
db 0x55, 0xaa