[org 0x7c00]
;; Main programm
cli                         ; disable interrupts
lgdt [GDT_Descriptor]       ; load the DGT table
; change last bit of cr0 to 1
mov eax, cr0
or eax, 1
mov cr0, eax
; ----- 32 bit protectd mode -----
; far jump
jmp CODESEG:start_protected_mode

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

[bits 32]
start_protected_mode:
    ; since the processor is in 32 bit mode now, we can't use the bios anymore
    ; because of this, we need to write to video memory directly to print text
    mov al, 'A'
    mov ah, 0x0f            ; White text on black background
    mov [0x0b8000], ax
    jmp $

times 510-($-$$) db 0       ; Fill the remaining space with zeros
db 0x55, 0xaa               ; Mark the disk as executable