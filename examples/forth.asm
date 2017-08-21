        CONVERT1251TOKOI8R OFF 
;        .LA     0
;        .ORG    0

        mov     #STACKA,        SP
        mov     #STACKR,        R4
        mov     #F4CORE,        R5
        mov     (R5)+,          PC

F4CORE:
        .word   IWORD_, hello, COUNT_, TYPE_

        .word   IWORD_, 0, IWORD_, 18., dump_             ; -- start count
; transimt T to UART
        .word   IWORD_, 'T', IWORD_, 0xFF70, STORE_
        .word   IWORD_, OK, COUNT_, TYPE_
; input from uart
getrx:
        .word   IWORD_, 0xFF70, IWORD_, 0xBFFF
getrx_char:
        .word   OVER_, FETCH_, OVER_, BIC_              ; * -- FF70 BFFF [FF70]&4000
        .word   BRZ_, getrx_char                        ; * -- FF70 BFFF  
        .word   OVER_, FETCH_, IWORD_, 0xFF00, BIC_     
        .word   DUP_, EMIT_
;        .word   IWORD_, 8., EQU_
        .word   IWORD_, 13., EQU_, BRZ_, getrx_char

        .word   DROP2_
        .word   IWORD_, OK, COUNT_, TYPE_

F4LOOP:
        .word   BR_, F4LOOP

SPACE_:
        jsr     R5,     F4VM
        .word   IWORD_, 32., EMIT_, RET_
CR_:
        jsr     R5,     F4VM
        .word   IWORD_, 13., EMIT_, RET_

COUNT_: ; COUNT - transform string (ptr_string -- address_string len_string)
        jsr     R5,     F4VM
        .word   DUP_, CFETCH_, RET_                     ; &hello, count

TYPE_:  ; string_addr string_len --
        jsr     R5,     F4VM
        .word   OVER_, ADD_, SWAP_                      ; &hello_end, &hello
output:
        .word   INC_, DUP_, CFETCH_                     ; &hello_end, &(hello+1), char
        .word   EMIT_                                   ; &hello_end, &(hello+1)
        .word   OVER_, OVER_, EQU_, BRZ_, output        ; &hello_end, &(hello+1)
        .word   DROP2_
        .word   RET_
HEX_:
        jsr     R5,     F4VM
        .word   IWORD_, 4
nexthex:
        .word   OVER_                                   ; value count -- value count value
        .word   IWORD_, 0x0FFF, BIC_, ROL4_             ; * -- 
        .word   IWORD_, hexTable, ADD_                  ; * -- value count value+&hextable
        .word   CFETCH_, EMIT_                          ; * -- value count  
        .word   DEC_                                    ; * -- value count-1  
        .word   SWAP_, SHL4_, SWAP_                     ; * -- value>>4 count 
        .word   DUP_, EQU0_, BRZ_, nexthex
        .word   DROP2_, RET_

dump_: ; dump output (start count -- )
        jsr     R5,     F4VM
        .word   OVER_, ADD_, SWAP_                      ; * -- stop start
nextdump:
        .word   DUP_, IWORD_, 0xFFF0, BIC_              ; * -- stop start start&0x000F
        .word   BRNZ_, continuedump                     ; * -- stop start
        .word   CR_, DUP_, HEX_                         ; * -- stop start 
        .word   SPACE_, SPACE_, SPACE_                  ; * -- stop start 
continuedump:
        .word   DUP_, FETCH_, HEX_                      ; * -- stop start
        .word   SPACE_                                  ; * -- stop start
        .word   INC2_, DUP2_                            ; * -- stop start+2 stop start+2
        .word   EQU_, BRZ_, nextdump                    ; * -- stop start+2
        .word   RET_


F4VM:
        mov     (SP)+,          -(R4)                   ; st -> st_ret
        mov     (R5)+,          PC
RET_:
        mov     (R4)+,          R5                      ; st_ret -> IP
        mov     (R5)+,          PC
IWORD_:
        mov     (R5)+,          -(SP)
        mov     (R5)+,          PC
DUP2_:  ; b c -- b c b c
        mov     2(SP),          -(SP)
OVER_:  ; b c -- b c b
        mov     2(SP),          -(SP)
        mov     (R5)+,          PC
SWAP_: ; b c -- c b
        mov     (SP)+,          R0
        mov     (SP),           -(SP)
        mov     R0,             2(SP)
        mov     (R5)+,          PC
DUP_:
        mov     (SP),           -(SP)
        mov     (R5)+,          PC
DROP_:
        add     #2,             SP
        mov     (R5)+,          PC
DROP2_:
        add     #4,             SP
        mov     (R5)+,          PC
ADD_:   
        add     (SP)+,          (SP)
        mov     (R5)+,          PC
BIC_:   
        bic     (SP)+,          (SP)
        mov     (R5)+,          PC
ROL4_:
        mov     (SP),           R0

        add     R0,             R0
        adc     R0
        add     R0,             R0
        adc     R0
        add     R0,             R0
        adc     R0
        add     R0,             R0
        adc     R0

        mov     R0,             (SP)
        mov     (R5)+,          PC
SHR4_:
        mov     (SP),           R0
        asr     R0
        asr     R0
        asr     R0
        asr     R0
        mov     R0,             (SP)
        mov     (R5)+,          PC
SHL4_:
        mov     (SP),           R0
        add     R0,             R0
        add     R0,             R0
        add     R0,             R0
        add     R0,             R0
        mov     R0,             (SP)
        mov     (R5)+,          PC
INC_:   
        add     #1,             (SP)
        mov     (R5)+,          PC
INC2_:   
        add     #2,             (SP)
        mov     (R5)+,          PC
DEC_:   
        sub     #1,             (SP)
        mov     (R5)+,          PC
EQU0_:   
        cmp     #0,             (SP)
        beq     equ_set1
        mov     #0,             (SP)
        mov     (R5)+,          PC
equ0_set1:
        mov     #0xFFFF,        (SP)
        mov     (R5)+,          PC
EQU_:   
        cmp     (SP)+,          (SP)
        beq     equ_set1
        mov     #0,             (SP)
        mov     (R5)+,          PC
equ_set1:
        mov     #0xFFFF,        (SP)
        mov     (R5)+,          PC
; branches
BR_:
        mov     (R5)+,          R5
        mov     (R5)+,          PC
BRZ_:
        cmp     #0,             (SP)+
        bne     br_skip
        mov     (R5)+,          R5
        mov     (R5)+,          PC
br_skip:
        add     #2,             R5
        mov     (R5)+,          PC
BRNZ_:
        cmp     #0,             (SP)+
        beq     br_skip
        mov     (R5)+,          R5
        mov     (R5)+,          PC
; memory access
STORE_:
        mov     2(SP),          @(SP)
        add     #4,             SP
        mov     (R5)+,          PC
FETCH_:
        mov     @(SP),          (SP)
        mov     (R5)+,          PC
CFETCH_:
        movb    @(SP),          (SP)
        mov     (R5)+,          PC
EMIT_:
; cursor hide
        mov     cursor,         R2
        add     #1,             cursor
        movb    #0x00,          512.(R2)        

        mov     (SP)+,          R0
; control code
        cmp     #13.,           R0
        beq     emit_CR
        cmp     #8.,            R0
        bne     putc
; backspace output
        sub     #1,             R2
        mov     R2,             cursor     
        mov     #0x0020,        R0              ; space
; symbol code
putc:
        sub     #0x0020,        R0              ; начинается с пробела - 32 
        add     R0,             R0              ; *2
        add     R0,             R0              ; *4
        add     R0,             R0              ; *8
        add     #0x0800,        R0              ; R0 -> font
        mov     R0,             R1
        add     #8.,            R1
emitc_loop:
        movb    (R0)+,          (R2)
        add     #64.,           R2
        cmp     R1,             R0
        bne     emitc_loop
cursor_paint:
        mov     cursor,         R0
        movb    #0xFF,          512.(R0)        
        mov     (R5)+,          PC
emit_CR:
        add     #512.,          R2
        bic     #0x01FF,        R2
        mov     R2,             cursor
        jmp     cursor_paint

hextable:
        .ASCII  "0123456789ABCDEF"
hello:
        .byte   17.
        .ASCII  "F4/11 CORE 0.003"
        .byte   13.
OK:
        .byte   5., 13.
        .ASCII  "F4> "

cursor:
        .word   0xB800       
        .word   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
STACKA:
        .word   0,0,0,0,0,0,0,0,0,0,0,0,0
STACKR:
.END