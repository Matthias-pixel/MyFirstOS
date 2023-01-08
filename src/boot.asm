[org 0x7c00]
KERNEL_LOCATION equ 0x1000
BOOT_DISK: db 0
SECTOR_COUNT: db 2
mov [BOOT_DISK], dl
initialize_registers:
    xor ax, ax                          
    mov es, ax
    mov ds, ax
    mov bp, 0x8000
    mov sp, bp

    mov bx, KERNEL_LOCATION
load_sectors_from_disk:
    mov ah, 2           ;; magic number
    mov al, [SECTOR_COUNT] ;; number of sectors to read
    mov ch, 0           ;; C ylinder number to start reading at
    mov dh, 0           ;; H ead     number to start reading at
    mov cl, 2           ;; S ector   number to start reading at
    mov dl, [BOOT_DISK]   ;; drive number to read from
    int 0x13
check_for_disk_load_error:
    jc disk_error
    cmp al, [SECTOR_COUNT]
    jne not_enough_sectors_error
switch_to_text_mode:
    mov ah, 0x0
    mov al, 0x3
    int 0x10
enter_protected_mode:
    cli                         ; disable interrupts
    lgdt [GDT_Descriptor]       ; load the DGT table
    ; change last bit of cr0 to 1
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    ; ----- 32 bit protectd mode -----
    ; far jump
    jmp CODESEG:start_protected_mode

;; --------------- Protected mode main ------------------------------------
[bits 32]
start_protected_mode:
    mov ax, DATASEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x90000
    mov esp, ebp

    jmp KERNEL_LOCATION

;; --------------- Error handling ------------------------
disk_error:
    mov ecx, disk_error_message
    call print_string
    hlt
not_enough_sectors_error:
    mov ecx, not_enough_sectors_error_message
    call print_string
    hlt
;; --------------- Print strings ------------------------
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
;; --------------- GDT-Table ----------------
GDT_Start:
    null_descriptor:
        dd 0                ; four times 00000000
        dd 0                ; four times 00000000
    code_descriptor:
        dw 0xffff           ; first 16 bits of the limit (size of the segment)
        dw 0                ; 16 bits +
        db 0                ; 8 bits = 24 bits of the base (start of the segment)
        db 0b10011010         ; presence, priviledge, type properties + Type flags
        db 0b11001111         ; other flags + last four bits of the limit (size of the segment)
        db 0                ; last 8 bits of the base
    data_descriptor:
        dw 0xffff           ; first 16 bits of the limit (size of the segment)
        dw 0                ; 16 bits +
        db 0                ; 8 bits = 24 bits of the base (start of the segment)
        db 0b10010010         ; presence, priviledge, type properties + Type flags
        db 0b11001111         ; other flags + last four bits of the limit (size of the segment)
        db 0                ; last 8 bits of the base
GDT_End:
GDT_Descriptor:
    dw GDT_End - GDT_Start - 1  ; size of the GDT table
    dd GDT_Start                ; start of the GDT table
CODESEG equ code_descriptor - GDT_Start
DATASEG equ data_descriptor - GDT_Start
; equ sets constants

;; --------------- Data ----------------
not_enough_sectors_error_message:
    db "Error: Not all sectors were read!", 13, 10, 0
disk_error_message:
    db "Error: Disk could not be read!", 13, 10, 0

;; --------------- End of bootloader ----------------
times 510-($-$$) db 0       ; Fill the remaining space with zeros
db 0x55, 0xaa               ; Mark the disk as executable