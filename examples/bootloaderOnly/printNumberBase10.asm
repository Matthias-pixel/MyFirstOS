[org 0x7c00]
;; Main programm
mov ecx, 4294967295          ;; Number to print
call print_number
jmp $

print_number:
    mov eax, ecx
    push ecx
    mov ecx, 0 
print_number_loop:
    ;; divmod by 10
        mov edx, 0
        mov ebx, 10         ;; Divide by 10
        div ebx             ;; divide eax/abx
    ;; edx: modulo
    ;; eax: remainder
    mov bl, dl
    add bl, '0'
    push ebx
    inc ecx
    cmp eax, 0
    jne print_number_loop
print_number_flush:
print_number_flush_loop:
    cmp ecx, 0
    je print_number_exit
    pop eax
    mov ah, 0x0e
    int 0x10
    dec ecx
    jmp print_number_flush_loop
print_number_exit:
    pop ecx
    ret

times 510-($-$$) db 0   ;; Fill the remaining space with zeros

;; Mark the disk as executable
db 0x55, 0xaa