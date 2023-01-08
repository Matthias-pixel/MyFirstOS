[org 0x7c00]
;; Main programm
mov [diskNum], dl
xor ax, ax
mov es, ax
mov ds, ax
mov bp, 0x8000
mov sp, bp

load_sectors_from_disk:
    mov ah, 2           ;; magic number
    mov al, [sectorNum] ;; number of sectors to read
    mov ch, 0           ;; C ylinder number to start reading at
    mov dh, 0           ;; H ead     number to start reading at
    mov cl, 2           ;; S ector   number to start reading at
    mov dl, [diskNum]   ;; drive number to read from
                        ;; 0x7e00: memory location to load the data to
    mov bx, 0x7e00      ;; (es*16)+bx = 0x7e00´
    int 0x13
check_for_disk_load_error:
    jc disk_error
    cmp al, [sectorNum]
    jne not_enough_sectors_error
call print_value
jmp $

print_value:
    ;; prints a value from the region loaded from disk
    mov ah, 0x0e
    mov al, [0x7e00]
    int 0x10
    ret
disk_error:
    mov ecx, disk_error_message
    call print_string
    hlt
not_enough_sectors_error:
    mov ecx, not_enough_sectors_error_message
    call print_string
    hlt

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
diskNum: db 0
sectorNum:
    db 4
not_enough_sectors_error_message:
    db "Error: Not all sectors were read!", 13, 10, 0
disk_error_message:
    db "Error: Disk could not be read!", 13, 10, 0
times 510-($-$$) db 0   ;; Fill the remaining space with zeros

;; Mark the disk as executable
db 0x55, 0xaa
db "A"
times (2048-1) db 0