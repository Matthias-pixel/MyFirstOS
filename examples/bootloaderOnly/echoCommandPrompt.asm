[org 0x7c00]
;; Main programm
mov ecx, (input_buffer+3)
await_command:
    ;; print '$ ' for command prompt
        mov ah, 0x0e
        mov al, `$`
        int 0x10
        mov al, ` `
        int 0x10
    ;;
command_loop:
    mov ah, 0                   ;; setup interupt 0x16 for reading from the keyboard
    int 0x16
    cmp al, 13                  ;; check if the user pressed enter
    je command_loop_print_command
    mov [ecx], al               ;; save typed character at ecx
    ;; print the typed character
        mov ah, 0x0e
        int 0x10
    ;;
    inc ecx                     ;; advance ecx pointer for next character
    jmp command_loop
    command_loop_print_command:
        ;; print '\r\n' for new line
            mov ah, 0x0e
            mov al, `\r`
            int 0x10
            mov al, `\n`
            int 0x10
        ;;
        mov [ecx], word 0           ;; Add NULL byte to terminate the string
        mov ecx, input_buffer       ;; reset ecx to the start to prepare for printing
        push ecx
        call print_string
        pop ecx
        ;; print '\r\n' for new line
            mov ah, 0x0e
            mov al, `\r`
            int 0x10
            mov al, `\n`
            int 0x10
        ;;
        jmp await_command

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

input_buffer:
    db "-> "
    times 61 db 0
times 510-($-$$) db 0   ;; Fill the remaining space with zeros

;; Mark the disk as executable
db 0x55, 0xaa