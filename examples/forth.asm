        CONVERT1251TOKOI8R OFF 
;        .LA     0
;        .ORG    0

        mov     #STACKA,        SP
        mov     #STACKR,        R4
        mov     #F4CORE,        R5
        mov     (R5)+,          PC

F4CORE:
        .word   IWORD_,  0x2355, DUP_, ADD_
        .word   IWORD_, hello
        .word   COUNT_, TYPE_, CR_

        .word   IWORD_, 0
        .word   IWORD_, 140.                              ; -- start count
        .word   OVER_, ADD_, SWAP_                      ; * -- stop start
nextdump:
        .word   DUP_, IWORD_, 0xFFF0, BIC_
        .word   EQU0_, BRF_, continuedump
        .word   CR_, DUP_, HEX_
        .word   SPACE_, SPACE_, SPACE_
continuedump:
        .word   DUP_, FETCH_, HEX_
        .word   SPACE_
        .word   INC2_, OVER_, OVER_                     ; * -- stop start+2 stop start+2
        .word   EQU_, BRF_, nextdump                    ; * -- stop start+2
F4LOOP:
;        .word   IWORD_, OK, COUNT_, TYPE_
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
        .word   OVER_, OVER_, EQU_, BRF_, output        ; &hello_end, &(hello+1)
        .word   DROP2_
        .word   RET_
HEX_:
        jsr     R5,     F4VM
        .word   IWORD_, 4
nexthex:
        .word   OVER_                                   ; value count -- value count value
        .word   IWORD_, 0x0FFF, BIC_, ROL4_
        .word   IWORD_, hexTable, ADD_                  ; * -- value count value+&hextable
        .word   CFETCH_, EMIT_                          ; * -- value count  
        .word   DEC_                                    ; * -- value count-1  
        .word   SWAP_, SHL4_, SWAP_                     ; * -- value>>4 count 
        .word   DUP_, EQU0_, BRF_, nexthex
        .word   DROP_, DROP_, RET_

F4VM:
        mov     (SP)+,          -(R4)                   ; st -> st_ret
        mov     (R5)+,          PC
RET_:
        mov     (R4)+,          R5                      ; st_ret -> IP
        mov     (R5)+,          PC
IWORD_:
        mov     (R5)+,          -(SP)
        mov     (R5)+,          PC
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
        rol     R0
        rol     R0
        rol     R0
        rol     R0
        rol     R0
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
BR_:
        mov     (R5)+,          R5
        mov     (R5)+,          PC
BRF_:
        cmp     #0xFFFF,        (SP)+
        beq     brf_skip
        mov     (R5)+,          R5
        mov     (R5)+,          PC
brf_skip:
        add     #2,             R5
        mov     (R5)+,          PC
FETCH_:
        mov     @(SP),          (SP)
        mov     (R5)+,          PC
CFETCH_:
        movb    @(SP),          (SP)
        mov     (R5)+,          PC
EMIT_:
        mov     (SP)+,          R0
        cmp     #13.,           R0
        beq     emit_CR
        sub     #0x0020,        R0              ; начинается с пробела - 32 
        add     R0,             R0              ; *2
        add     R0,             R0              ; *4
        add     R0,             R0              ; *8
        add     #0x0800,        R0              ; R0 -> font
        mov     R0,             R1
        add     #8.,            R1
        mov     cursor,         R2
        add     #1,             cursor
emitc_loop:
        movb    (R0)+,          (R2)
        add     #64.,           R2
        cmp     R1,             R0
        bne     emitc_loop
        mov     (R5)+,          PC
emit_CR:
        add     #512.,          cursor
        bic     #0x01FF,        cursor
        mov     (R5)+,          PC

hextable:
        .ASCII  "0123456789ABCDEF"
hello:
        .byte   17.
        .ASCII  "F4/11 CORE v0.002"
OK:
        .byte   5.
        .ASCII  "F4/> "

cursor:
        .word   0xC000       
        .word   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
STACKA:
        .word   0,0,0,0,0,0,0,0,0,0,0,0,0
STACKR:
.END