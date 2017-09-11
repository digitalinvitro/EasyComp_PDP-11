        CONVERT1251TOKOI8R OFF 
;        .LA     0
;        .ORG    0
;
; STACKR -> B6C0..B680 : 
; STACKA -> B7A0..B6B0 : 
; buffer -> B7B0..B800 : 80
        mov     #0xB7A0,        SP
        mov     #0xB6C0,        R4
        mov     #F4CORE,        R5
        mov     (R5)+,          PC

F4CORE:
        .word   IWORD_, hello, COUNT_, TYPE_

;        .word   IWORD_, 0, IWORD_, 18., dump_             ; -- start count
; transimt T to UART
        .word   IWORD_, 'T', IWORD_, 0xFF70, STORE_
work:
; приглашение к вводу "глубина стека:F>"
        .word   DEEP_, CR_, HEX_, IWORD_, OK, COUNT_, TYPE_
        .word   HIB_, FIB_, STORE_
; input from uart
getrx:
        .word   IWORD_, 0xFF70, IWORD_, 0xBFFF
getrx_char:
        .word   OVER_, FETCH_, OVER_, BIC_              ; * -- FF70 BFFF [FF70]&4000
        .word   BRZ_, getrx_char                        ; * -- FF70 BFFF  
        .word   OVER_, FETCH_, IWORD_, 0xFF00, BIC_     ; * -- FF70 BFFF [FF70]&00FF

        .word   DUP_, EMIT_
        .word   DUP_, IWORD_, 8., EQU_, BRZ_, cmp_next
; --- Back space
        .word   DROP_, FIB_, FETCH_, DEC_               ; FF70 BFFF char -- FF70 BFFF *fib-1
        .word   IWORD_, 32., OVER_                      ; * -- FF70 BFFF *fib-1 0x32 *fib-1
        .word   CSTORE_                                 ; * -- FF70 BFFF *fib-1
        .word   FIB_                                    ; * -- FF70 BFFF *fib-1 fib
        .word   STORE_, BR_, getrx_char                 ; * -- FF70 BFFF 
cmp_next:
        .word   FIB_, FETCH_, OVER_, OVER_              ; * -- FF70 BFFF char *fib char *fib
        .word   CSTORE_                                 ; * -- FF70 BFFF char *fib
        .word   INC_, FIB_, STORE_                      ; * -- FF70 BFFF char 
        .word   IWORD_, 13., EQU_, BRZ_, getrx_char     ; * -- FF70 BFFF 
        .word   DROP2_                                  ; * --
        .word   HIB_, PAD_, STORE_                      ; * --

; debug print input string
;        .word   HIB_, IWORD_, 40, TYPE_, CR_
; seek in dictionary
seek_dictionary:
        .word   PAD_, FETCH_, HERE_, DEC_, BR_, cmpstr  ;  -- *pad+1 *here-1 
next_cmpchar:
        .word   DROP2_
        .word   DEC_, SWAP_, INC_, SWAP_                ; *pad *here -- *pad+1 *here-1
cmpstr:
        .word   OVER_, CFETCH_                          ; * -- *pad+1 *here-1 pad_ch 
        .word   OVER_, CFETCH_                          ; * -- *pad+1 *here-1 pad_ch here-1_ch

        .word   DUP2_                                   ; * -- *pad+1 *here-1 pad_ch here-1_ch pad_ch here-1_ch
        .word   EQU_, BRNZ_, next_cmpchar               ; * -- *pad+1 *here-1 pad_ch here-1_ch
;
; символ словарного слова не равен символу из буфера ввода
;
        .word   BRNZ_, cmp_fault                        ; *pad+1 *here-1 pad_ch here-1_ch -- *pad+1 *here-1 pad_ch 
; обнаружен конечный символ словарного слова - null
;
        .word   DUP_, IWORD_, 13., EQU_                 ; * -- *pad+1 *here-1 pad_ch pad_ch==CR
        .word   SWAP_, IWORD_, 32., EQU_                ; * -- *pad+1 *here-1 pad_ch==CR pad_ch==SPACE
        .word   OR_, BRZ_, cmp_fault0                   ; * -- *pad+1 *here-1 
;
; поиск успешен, выравниваем указатель в словаре
;
        .word   DUP_, IWORD_, 0xFFFE, BIC_, SUB_        ; * -- *pad+1 *here-1 odd(*here-1)
        .word   IWORD_, 2, SUB_, FETCH_                 ; * -- *pad+1 exec_addr
        .word   SWAP_                                   ; * -- exec_addr *pad
;
; пропустить в PAD все подряд идущие пробелы 
;
        .word   IWORD_, ' ', SWAP_, SKIPC_              ; * -- exec_addr *new_pad
        .word   PAD_, STORE_                            ; * -- exec_addr 
; debug parameter for execute
;        .word   IWORD_, find, COUNT_, TYPE_
        .word   EXEC_
seek_dic_next:
        .word   PAD_, FETCH_, CFETCH_, IWORD_, 13., EQU_ ; если не возврат каретки продолжить поиск в словаре после выполнения
        .word   BRNZ_, work
        .word   BR_, seek_dictionary

; ошибка поиска, указатель поиска на каком то из символов наименования слова
;   ситуация когда введенное слово не совпало по символьно с словом в словаре, а до конца слова поиск не дошел
;  - поиск надо продолжить
cmp_fault: 
        .word   DROP_
;        .word   CR_, EMIT_                              ; *pad+1 *here-1 pad_ch -- *pad+1 *here-1 
seek_0:
        .word   DEC_, DUP_, CFETCH_, BRNZ_, seek_0      ; * -- pad+1 here
; ошибка поиска, указатель поиска на терминирующем символе 
;   ситуация когда введенное слово совпадает частично, но при этом длинее сравниваемого слова в словаре
;   - поиск необходимо продолжить
cmp_fault0:
;        .word   IWORD_, unfind, COUNT_, TYPE_
continue_seek:
        .word   NIP_                                    ; *pad+1 *here-1 -- *here-1 

        .word   DUP_, IWORD_, 0xFFFE, BIC_              ; * *here-1 -- *here-1 *here-1&0xFFFE
        .word   SUB_                                    ; * -- odd(*here-1)
        .word   IWORD_, 3, SUB_                         ; * -- *here.next

        .word   PAD_, FETCH_, SWAP_                     ; * -- *pad *here.next
        .word   DUP_, FETCH_                            ; * -- *pad *here.next pad_word 
        .word   BRNZ_, cmpstr                           ; * -- *pad *here.next 
        .word   DROP_

;        .word   IWORD_, topd, COUNT_, TYPE_             ; * -- *pad *here.next 
        .word   IWORD_, 0, OVER_, CFETCH_
next_val:
        .word   IWORD_, '0', SUB_                       ; -- pad val *pad-0x30=0..9|17..22
        .word   DUP_, BRS_, fault                       ; check for digit < 0 (-- pad val *pad-0x30 )
        .word   DUP_, IWORD_, 10., SUB_, BRS_, make     ; check for digit in 0..9
; digit is A..F(17..22)
        .word   IWORD_, 7., SUB_                        ; -- pad val *pad-7
        .word   DUP_, IWORD_, 16., SUB_, BRNS_, fault   ; check for digit > 15
make:
        .word   SWAP_, SHL4_, OR_                       ; -- pad val<<4|digit
        .word   SWAP_, INC_, SWAP_, OVER_, CFETCH_      ; -- pad++ val *(pad++)
        .word   DUP_, IWORD_, ' ', EQU_                 ; -- pad++ val *(pad++) *(pad++)==' '
        .word   OVER_, IWORD_, 13., EQU_                ; -- pad++ val *(pad++) *(pad++)==' ' *(pad++)==13
        .word   OR_, BRZ_, next_val                     ; -- pad++ val *(pad++)
        .word   DROP_                                   ; -- pad++ val
        .word   SWAP_                                   ; -- val pad++

        .word   IWORD_, ' ', SWAP_                      ; * -- val ' ' pad++
        .word   SKIPC_                                  ; * -- val *new_pad 
        .word   PAD_, STORE_                            ; * -- val

       
        .word   BR_, seek_dic_next                      ; work

fault:
        .word   INITST_
        .word   IWORD_, seekerr, COUNT_, TYPE_
        .word   BR_, work
;*************************************************** CORE END *****************************************************************************
;F4LOOP:
;        .word   BR_, F4LOOP

INITST_:
        mov     #0xB7A0,        SP
        mov     #0xB6C0,        R4
        mov     (R5)+,          PC

SKIPC_: ; пропуск символа в строке   ( char addr -- new_addr)
        jsr     R5,     F4VM
skipc_loop:
        .word   DUP2_                                  ; * -- skip_ch addr skip_ch addr 
        .word   CFETCH_, EQU_, BRZ_, skipc_exit        ; * -- skip_ch addr *addr==skip_ch
        .word   INC_, BR_, skipc_loop                  ; * -- skip_ch addr++
skipc_exit:
        .word   NIP_, RET_

SPACE_:
        jsr     R5,     F4VM
        .word   IWORD_, 32., EMIT_, RET_
CR_:
        jsr     R5,     F4VM
        .word   IWORD_, 13., EMIT_, RET_

COUNT_: ; COUNT - transform string (ptr_string -- address_string len_string)
        jsr     R5,     F4VM
        .word   DUP_, INC_, SWAP_, CFETCH_,  RET_       ; -- &hello-1 count

TYPE_:  ; string_addr string_len --
        jsr     R5,     F4VM
        .word   OVER_, ADD_, DEC_, SWAP_, DEC_          ; &hello_end, &hello
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
        .word   DROP2_
        .word   RET_

EXEC_: ; -- addr
        mov     R5,             -(R4)
        mov     (SP)+,          PC
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
DUP_:
        mov     (SP),           -(SP)
        mov     (R5)+,          PC
NIP_: ; a b -- b
        mov     (SP)+,          (SP)
        mov     (R5)+,          PC
SWAP_: ; b c -- c b
        mov     (SP)+,          R0
        mov     (SP),           -(SP)
        mov     R0,             2(SP)
        mov     (R5)+,          PC
DROP_:
        add     #2,             SP
        mov     (R5)+,          PC
DROP2_:
        add     #4,             SP
        mov     (R5)+,          PC
OR_:   
        bis     (SP)+,          (SP)
        mov     (R5)+,          PC
ADD_:   
        add     (SP)+,          (SP)
        mov     (R5)+,          PC
SUB_:   
        sub     (SP)+,          (SP)
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
BRNS_:
        mov     (SP)+,          R0
        bmi     br_skip
        mov     (R5)+,          R5
        mov     (R5)+,          PC
BRS_:
        mov     (SP)+,          R0
        bpl     br_skip
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
CSTORE_:
        movb    2(SP),          @(SP)
        add     #4,             SP
        mov     (R5)+,          PC
FETCH_:
        mov     @(SP),          (SP)
        mov     (R5)+,          PC
CFETCH_:
        movb    @(SP),          R0
        bic     #0xFF00,        R0
        mov     R0,             (SP)
        mov     (R5)+,          PC
; system constant - pointer, address, etc
HERE_:   ; pointer to last forth paragraph
        mov     #HERE,          -(SP)
        mov     (R5)+,          PC
DEEP_:
        mov     #0xB7A0,        R0
        sub     SP,             R0
        mov     R0,             -(SP)
        mov     (R5)+,          PC
PAD_:   ; pointer to forth word in buffer
        mov     #PAD,           -(SP)
        mov     (R5)+,          PC
HIB_:   ; start position to input buffer
        mov     #0xB7B0,        -(SP)
        mov     (R5)+,          PC
FIB_:   ; current position to input buffer
        mov     #FIB,           -(SP)
        mov     (R5)+,          PC
EMIT_:
; cursor hide
        mov     cursor,         R2
        add     #1,             cursor
        movb    #0x00,          448.(R2)        

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
        movb    #0xFF,          448.(R0)        
        mov     (R5)+,          PC
emit_CR:
        bic     #0x003F,        R2
        cmp     #0xF600,        R2
        bne     emit_CR0
; scroll
        mov     #8.,            R3
scroll_screen:
        mov     #0xB800,        R0
scroll_line:
        mov     64.(R0),        (R0)+
        cmp     #0xF7C0,        R0
        bne     scroll_line
; clear bottom line
clr_top_line:
        movb    #0,             (R0)+
        cmp     #0xF800,        R0
        bne     clr_top_line

        sub     #1,             R3
        bne     scroll_screen
        jmp     emit_CR1
emit_CR0:
        add     #512.,          R2
emit_CR1:
        mov     R2,             cursor
        jmp     cursor_paint

VALH_:
        
        .word   0x0000
        .word   HEX_
        .word   0 
        .ASCII  "xeh."
        .word   ADD_
        .byte   0 
        .ASCII  "+"
        .word   SUB_
        .byte   0 
        .ASCII  "-"
        .word   CFETCH_
        .word   0 
        .ASCII  "@C"
        .word   FETCH_
        .byte   0 
        .ASCII  "@"
        .word   CSTORE_
        .word   0 
        .ASCII  "!C"
        .word   STORE_
        .byte   0 
        .ASCII  "!"
        .word   EXEC_
        .word   0 
        .ASCII  "og"
        .word   dump_
        .word   0 
        .ASCII  "pmud"
HERE:

        align   2

hextable:
        .ASCII  "0123456789ABCDEF"
hello:
        .byte   17.
        .ASCII  "F4/11 CORE 0.006"
        .byte   13.
OK:
        .byte   4. 
        .ASCII  ":F>"
topd:
        .byte   7., 13.
        .ASCII  "topd !"
find:
        .byte   7., 13.
        .ASCII  "find !"
unfind:
        .byte   5. 
        .ASCII  " uf!"
        .byte   13.
seekerr:
        .byte   3. 
        .ASCII  " ??"
PAD:
        .word   0xB7B0
FIB:
        .word   0xB7B0
cursor:
        .word   0xB800       
;        .word   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;STACKA:
;        .word   0,0,0,0,0,0,0,0,0,0,0,0,0
;STACKR:
;buffer:
;        .ASCII  "0123456789012345678901234567890123456789"
.END