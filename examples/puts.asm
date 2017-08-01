        .LA     0
        .ORG    0

        mov     #ENDRAM,        SP
        jsr     R5,             puts
        .byte   0x31,0x38,0x30,0x31,0xC2,0xCC,0x31,0x3A,0x20,0xD1,0xEB,0xF3,0xE6,0xF3,0x20,0xF1,0xEE,0xE2,0xE5,0xF2,0xF1,0xEA,0xEE,0xEC,0xF3,0x20,0xF1,0xEE,0xFE,0xE7,0xF3,0x20,0x21,0x0
;        .ASCIZ  "1801ВМ1: Служу Советскому Союзу !"

halt:
        jmp     halt

puts:
        push    R3
        push    R4
puts_char:
        movb    (R5)+,          R4        
        bic     #0xFF00,        R4
        cmp     #0,             R4
        beq     puts_exit
        jsr     R3,             putc
        jmp     puts_char
puts_exit:
        bit     #1,             R5
        beq     puts_exit0
        add     #1,             R5
puts_exit0:
        pop     R4
        pop     R3
        rts     R5        

putc:
        push    R0
        push    R1

        mov     cursor,         R0
        add     #1,             cursor
        sub     #0x0020,        R4              ; начинается с пробела - 32 
        add     R4,             R4              ; *2
        add     R4,             R4              ; *4
        add     R4,             R4              ; *8
        add     #0x0800,        R4              ; R4 -> font
        mov     R4,             R1
        add     #8.,            R4
putc_loop:
        movb    (R1)+,          (R0)
        add     #64.,           R0
        cmp     R4,             R1
        bne     putc_loop
        
        pop     R1
        pop     R0
        rts     R3

cursor: .WORD  140000
        
        .ASCIZ  "                             "

ENDRAM:
.END