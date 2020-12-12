*-----------------------------------------------------------
* Title      : Dis-assembler
* Written by : Team Awesome
* Date       :
* Description:
*-----------------------------------------------------------

START    ORG    $1000      ; first instruction of program

ALL_REG REG D0-D7/A0-A6

; Opcodes follow specific patterns
* MOVE, MOVEA
* 0 0 ? ?
OPMOVE EQU %00
* NOP, MOVEM, LEA, NOT, JSR, RTS
* 0 1 0 0 
OPSPECIAL    EQU %0100
* ADDQ
* 0 1 0 1
OPADDQ  EQU %0101
* BGT, BLE, BEQ, BRA
* 0 1 1 0
OPBRA   EQU %0110
* MOVEQ
* 0 1 1 1
OPMOVEQ EQU %0111
* OR
* 1 0 0 0
OPOR    EQU %1000
* SUB
* 1 0 0 1
OPSUB   EQU %1001
* AND
* 1 1 0 0
OPAND   EQU %1001
* ADD, ADDA
* 1 1 0 1
OPADD   EQU %1101
* LSL, LSR, ASL, ASR, ROL, ROR
* 1 1 1 0
OPSHIFT EQU %1110

;Reference number for OPCODE to EA
opcodeRef  EQU  %00000000

* start of program

* start of IO
IO:
    ; assume that current instruction we are reading is
    ; pointed by A0
    ; this is totally up to IO part, so it is subjected to change
    ; for debugging purpose, imagine NOP is the current instruction we are reading
    
    LEA TEST, A0
    
    JSR OPCODES

*-----------------------------------------------------------
* Preconditions:
*   - A4 pointing to the opcode name (null terminated string)
*   - D4 contains size (0 for ignore, 1 for Byte, 2 for Word, 3 for Long
*-----------------------------------------------------------
IO_PRINT_OPCODES:
    ; TODO: something...
    RTS
* end of IO

* start of OpCodes

*-----------------------------------------------------------
* Decode OpCodes
*
* Preconditions:
*   - A0 must be pointing to the beginning of the instruction
*-----------------------------------------------------------
OPCODES:    
    ; start of decoding
    MOVEM.L ALL_REG, -(SP) ; store current register state
    
    ; first two bits will decide if it's MOVE
    ; %00 will indicate MOVE or other opcodes otherwise
    MOVE.B  (A0), D5
    AND.B #$C0, D5 ; extract 2 most significant bits out of 8 bits
    LSR.B #6, D5 ; shift 6 bits right to get the actual value
 
    CMP.B #OPMOVE, D5 ; compare %00
    BNE OPCODES_OTHERS ; skip to other opcodes
    ; or continue to OPCODES_MOVE
    
OPCODES_MOVE: ; either MOVE or MOVEA
    MOVE.W  (A0), D5
    AND.W   #$0FFF, D5 ; use 12 least significant bits
    LSR.W   #6, D6 ; shift right 6 bits to get 6 MSB
    AND.W   #$0007, D6 ; interested only in last 3 bits
    
    CMP.W   #%001,  D6 ; is dest mode 001? then it is MOVEA, or else, MOVE
    BEQ     OPCODES_MOVEA
    
    MOVE.L  #2, opcodeRef
    LEA Name_Move, A4
    BRA OPCODES_MOVE_SIZES

OPCODES_MOVEA:
    MOVE.L  #3, opcodeRef
    LEA Name_Movea, A4
    BRA OPCODES_MOVE_SIZES
    
OPCODES_MOVE_SIZES:
    MOVE.B  (A0), D5
    AND.B   #$30, D5 ; use 3rd and 4th bits
    LSR.B   #4, D5 ; shift right 4 bits to get the value
    
    CMP.B   #%01, D5 ; Byte
    BEQ OPCODES_MOVE_SIZES_B
    
    CMP.B   #%11, D5 ; Word
    BEQ OPCODES_MOVE_SIZES_W
    
    CMP.B   #%10, D5 ; Long
    BEQ OPCODES_MOVE_SIZES_L
    
    BRA OPCODES_INVALID ; invalid size

OPCODES_MOVE_SIZES_B:
    MOVE.L  #1, D4
    BRA OPCODES_MOVE_SIZES_END

OPCODES_MOVE_SIZES_W:
    MOVE.L  #2, D4
    BRA OPCODES_MOVE_SIZES_END

OPCODES_MOVE_SIZES_L:
    MOVE.L  #3, D4
    BRA OPCODES_MOVE_SIZES_END

OPCODES_MOVE_SIZES_END:
    JSR IO_PRINT_OPCODES ; A4 pointing to the op name, D4 contains op size
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

OPCODES_OTHERS: ; any other OPCODES
    MOVE.B  (A0), D5
    AND.B   #$F0, D5 ; extract 4 most significant bits out of 8 bits
    LSR.B   #4, D5 ;shift 4 bits right to get the actual value
    
    CMP.B   #OPSPECIAL, D5
    BEQ OPCODES_SPECIAL
    
    CMP.B   #OPADDQ, D5
    BEQ OPCODES_ADDQ
    
    CMP.B   #OPBRA, D5
    BEQ OPCODES_BRA

    CMP.B   #OPMOVEQ, D5
    BEQ OPCODES_MOVEQ
    
    ;TODO: add more opcodes
    
    CMP.B   #OPOR, D5
    BEQ OPCODES_MOVEQ
    
    CMP.B   #OPSUB, D5
    BEQ OPCODES_MOVEQ
    
    CMP.B   #OPAND, D5
    BEQ OPCODES_MOVEQ
    
    CMP.B   #OPADD, D5
    BEQ OPCODES_MOVEQ
    
    CMP.B   #OPSHIFT, D5
    BEQ OPCODES_MOVEQ
    
    ; if code doesn't match with any, it's an invalid opcode
    BRA OPCODES_INVALID

OPCODES_SPECIAL:
    MOVE.W  (A0), D5
    AND.W #$0FFF, D5 ; use 12 least significant bits
    
    MOVE.W  D5, D6
    LSR.W   #1, D6
    LSR.W   #8, D6 ; shift right 9 bits to get the 3 MSB
    CMP.W   #%111,  D6 ; starts with 111 means NOP, JSR, or RTS
    BEQ OPCODES_SPECIAL_NOPJSRRTS
    
    MOVE.W  D5, D6
    LSR.W   #8, D6 ; shift right 8 bits to get the 4 MSB
    AND.W   #$1, D6 ; to check if LEA, we only need to see if 4th bit is set
    CMP.W   #%1,  D6 ; if 4th bit is set, it must be LEA 
    BEQ OPCODES_SPECIAL_LEA
    
    MOVE.W  D5, D6
    LSR.W   #3, D6
    LSR.W   #8, D6 ; shift right 11 bits to get the 1 MSB
    CMP.W   #%1, D6 ; if 1st bit is 1, it's MOVEM, or else, it's NOT
    BEQ OPCODES_SPECIAL_MOVEM
    
    BRA OPCODES_SPECIAL_NOT
    
OPCODES_SPECIAL_NOPJSRRTS:
    MOVE.W  D5, D6
    LSR.W   #7, D6 ; shift right 7 bits to get 5 MSB
    AND.W   #$1, D6 ; only need to see if 5th bit is set
    CMP.W   #%1, D6 ; if it's set, it is JSR
    BEQ OPCODES_SPECIAL_JSR
    
    MOVE.W  D5, D6
    LSR.W   #2, D6 ; shift right 2 bits to get 3rd LSB
    AND.W   #$1, D6 ; only interested in last bit
    CMP.W   #%1, D6 ; if it's set, it is RTS, or else, NOP
    BEQ OPCODES_SPECIAL_RTS
    
    BRA OPCODES_SPECIAL_NOP
    
OPCODES_SPECIAL_NOP:
    MOVE.L  #0, D4
    LEA Name_Nop, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #4, opcodeRef
    JSR EFFECTIVEADDRESS
    
    BRA OPCODES_END
    
OPCODES_SPECIAL_JSR:
    MOVE.L  #0, D4
    LEA Name_Jsr, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #8, opcodeRef
    JSR EFFECTIVEADDRESS
    
    BRA OPCODES_END
    
OPCODES_SPECIAL_RTS:
    MOVE.L  #0, D4
    LEA Name_Rts, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #9, opcodeRef
    JSR EFFECTIVEADDRESS
    
    BRA OPCODES_END
    
OPCODES_SPECIAL_LEA:
    MOVE.L  #3, D4
    LEA Name_Lea, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #6, opcodeRef
    JSR EFFECTIVEADDRESS
    
    BRA OPCODES_END
    
OPCODES_SPECIAL_MOVEM:
    MOVE.L  #5, opcodeRef
    BRA OPCODES_SPECIAL_MOVEM_SIZES

OPCODES_SPECIAL_MOVEM_SIZES:
    MOVE.W  (A0), D5
    AND.W   #$0040, D5 ; 10th bit
    LSR.W   #6, D5 ; shift right 6 bits to get the value
    
    CMP.W   #0, D5
    BEQ OPCODES_SPECIAL_MOVEM_SIZES_W
    
    ; it's either 0 or 1, so no invalid case
    BRA OPCODES_SPECIAL_MOVEM_SIZES_L

OPCODES_SPECIAL_MOVEM_SIZES_W:
    MOVE.L  #2, D4
    BRA OPCODES_SPECIAL_MOVEM_SIZES_END

OPCODES_SPECIAL_MOVEM_SIZES_L:
    MOVE.L  #3, D4
    BRA OPCODES_SPECIAL_MOVEM_SIZES_END
    
OPCODES_SPECIAL_MOVEM_SIZES_END:
    LEA Name_Movem, A4
    JSR IO_PRINT_OPCODES
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

OPCODES_SPECIAL_NOT:
    MOVE.L  #7, opcodeRef
    
    MOVE.W  (A0), D5
    AND.W   #$00C0, D5 ; 9th and 10th bits
    LSR.W   #6, D5 ; shift right 6 bits to get the value
    
    CMP.W   #%00, D5
    BEQ OPCODES_SPECIAL_NOT_SIZES_B
    
    CMP.W   #%01, D5
    BEQ OPCODES_SPECIAL_NOT_SIZES_W
    
    CMP.W   #%10, D5
    BEQ OPCODES_SPECIAL_NOT_SIZES_L
    
    BRA OPCODES_INVALID
   
OPCODES_SPECIAL_NOT_SIZES_B:
    MOVE.L  #1, D4
    BRA OPCODES_SPECIAL_NOT_SIZES_END
 
OPCODES_SPECIAL_NOT_SIZES_W:
    MOVE.L  #2, D4
    BRA OPCODES_SPECIAL_NOT_SIZES_END

OPCODES_SPECIAL_NOT_SIZES_L:
    MOVE.L  #3, D4
    BRA OPCODES_SPECIAL_NOT_SIZES_END

OPCODES_SPECIAL_NOT_SIZES_END:
    LEA Name_Not, A4
    JSR IO_PRINT_OPCODES
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
OPCODES_ADDQ:
    MOVE.L  #10, opcodeRef 
    BRA OPCODES_ADDQ_SIZES
    
OPCODES_ADDQ_SIZES:
    MOVE.W  (A0), D5
    AND.W   #$00C0, D5 ; 9th and 10th bits
    LSR.W   #6, D5 ; shift right 6 bits to get the value
    
    CMP.W   #%00, D5
    BEQ OPCODES_ADDQ_SIZES_B
    
    CMP.W   #%01, D5
    BEQ OPCODES_ADDQ_SIZES_W
    
    CMP.W   #%10, D5
    BEQ OPCODES_ADDQ_SIZES_L
    
    BRA OPCODES_INVALID

OPCODES_ADDQ_SIZES_B:
    MOVE.L  #1, D4
    BRA OPCODES_ADDQ_SIZES_END
    
OPCODES_ADDQ_SIZES_W:
    MOVE.L  #2, D4
    BRA OPCODES_ADDQ_SIZES_END
    
OPCODES_ADDQ_SIZES_L:
    MOVE.L  #3, D4
    BRA OPCODES_ADDQ_SIZES_END

OPCODES_ADDQ_SIZES_END:
    LEA Name_Addq, A4
    JSR IO_PRINT_OPCODES
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
OPCODES_BRA:
    MOVE.W  (A0), D5
    AND.W   #$0F00, D5 ; extract 5th, 6th, 7th, and 8th bits
    LSR.W   #8, D5 ; shift 8 bits right to get the value
    
    CMP.W   #%1110, D5
    BEQ OPCODES_BGT
    
    CMP.W   #%1111, D5
    BEQ OPCODES_BLE
    
    CMP.W   #%0111, D5
    BEQ OPCODES_BEQ
    
    CMP.W   #%0000, D5
    BNE OPCODES_INVALID ; this is the last possible case, so if didn't match, then it's not a valid opcode.
    
    MOVE.L  #0, D4
    LEA Name_Bra, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #14, opcodeRef ; otherwise, it's BRA
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
OPCODES_BGT:
    MOVE.L  #0, D4
    LEA Name_Bgt, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #11, opcodeRef
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
OPCODES_BLE:
    MOVE.L  #0, D4
    LEA Name_Ble, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #12, opcodeRef
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

OPCODES_BEQ:
    MOVE.L  #0, D4
    LEA Name_Beq, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #13, opcodeRef
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
OPCODES_MOVEQ:
    MOVE.L  #3, D4
    LEA Name_Moveq, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #15, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

; TODO: the rest of opcodes

OPCODES_OR:
    MOVE.L  #0, D4
    LEA Name_Or, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #16, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_ADD_SIZES

OPCODES_SUB:
    MOVE.L  #0, D4
    LEA Name_Sub, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #17, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_ADD_SIZES
    
OPCODES_AND:
    MOVE.L  #0, D4
    LEA Name_And, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #18, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_ADD_SIZES

OPCODES_ADD:
    MOVE.W  (A0), D5
    AND.W   #$0FFF, D5 ; use 12 least significant bits
    LSR.W   #6, D6 ; shift right 6 bits to get 6 MSB
    AND.W   #$0007, D6 ; interested only in last 3 bits
    
    CMP.W   #%001,  D6 ; is dest mode 001? then it is ADDA, or else, ADD
    BEQ     OPCODES_ADDA
    
    MOVE.L  #0, D4
    LEA Name_Add, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #19, opcodeRef
    JSR EFFECTIVEADDRESS
    BRA OPCODES_ADD_SIZES

OPCODES_ADDA:
    MOVE.L  #0, D4
    LEA Name_Adda, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #20, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_ADD_SIZES
    
OPCODES_ADD_SIZES: ; all of the or,sub,and,add,adda
    MOVE.L  (A0), D5
    AND.L   #$01C0, D5 ; use 8th, 9th and 10th bits
    LSR.L   #6, D5 ; shift right 6 bits to get the value
    
    CMP.L   #%000, D5 ; Byte
    BEQ OPCODES_ADD_SIZES_B
    
    CMP.L   #%100, D5 ; Byte
    BEQ OPCODES_ADD_SIZES_B
    
    CMP.L   #%001, D5 ; Word
    BEQ OPCODES_ADD_SIZES_W
    
    CMP.L   #%101, D5 ; Word
    BEQ OPCODES_ADD_SIZES_W
    
    CMP.L   #%110, D5 ; Long
    BEQ OPCODES_ADD_SIZES_L
    
    CMP.L   #%010, D5 ; Long
    BEQ OPCODES_ADD_SIZES_L
    
    BRA OPCODES_INVALID ; invalid size

OPCODES_ADD_SIZES_B:
    MOVE.L  #1, D4
    BRA OPCODES_END

OPCODES_ADD_SIZES_W:
    MOVE.L  #2, D4
    BRA OPCODES_END

OPCODES_ADD_SIZES_L:
    MOVE.L  #3, D4
    BRA OPCODES_END
    
OPCODES_LSL:
    MOVE.W  (A0), D5
    AND.W   #$0100, D5 ; extract 8th bit
    LSR.W   #8, D5 ; shift 8 bits right to get the value
    
    CMP.W   #%1, D5
    BEQ OPCODES_LSR
    
    MOVE.W  (A0), D5
    AND.W   #$0018, D5 ; extract 3th and 4th bits
    LSR.W   #4, D5 ; shift 4 bits right to get the value at index 3 and 4
    LSR.W   #8, D5 ; shift 8 bits right to get the value at index 3 and 4
    
    CMP.W   #%00, D5
    BEQ OPCODES_ASL
    
    CMP.W   #%11, D5
    BEQ OPCODES_ROL
    
    CMP.W   #%10, D5
    BNE OPCODES_INVALID ; this is the last possible case, so if didn't match, then it's not a valid opcode.
    
    MOVE.L  #0, D4
    LEA Name_Lsl, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #21, opcodeRef ; otherwise, it's LSL
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
    
OPCODES_LSR:
    MOVE.W  (A0), D5
    AND.W   #$0018, D5 ; extract 3th and 4th bits
    LSR.W   #4, D5 ; shift 4 bits right to get the value at index 3 and 4
    LSR.W   #8, D5 ; shift 8 bits right to get the value at index 3 and 4
    
    CMP.W   #%00, D5
    BEQ OPCODES_ASR
    
    CMP.W   #%11, D5
    BEQ OPCODES_ROR
    
    CMP.W   #%10, D5
    BNE OPCODES_INVALID ; this is the last possible case, so if didn't match, then it's not a valid opcode.
    
    MOVE.L  #0, D4
    LEA Name_Lsr, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #22, opcodeRef ; otherwise, it's LSR
    JSR EFFECTIVEADDRESS
    BRA OPCODES_SHIFTING_SIZES
    
OPCODES_ASL:
    MOVE.L  #0, D4
    LEA Name_Asl, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #23, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_SHIFTING_SIZES

OPCODES_ASR:
    MOVE.L  #0, D4
    LEA Name_Asr, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #24, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_SHIFTING_SIZES

OPCODES_ROL:
    MOVE.L  #0, D4
    LEA Name_Rol, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #25, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_SHIFTING_SIZES

OPCODES_ROR:
    MOVE.L  #0, D4
    LEA Name_Ror, A4
    JSR IO_PRINT_OPCODES
    
    MOVE.L  #26, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_SHIFTING_SIZES
    
OPCODES_SHIFTING_SIZES: ; all of the lsl,lsr,asl,asr,rol,ror
    MOVE.L  (A0), D5
    AND.L   #$00C0, D5 ; use 3rd and 4th bits
    LSR.L   #5, D5 ; shift right 4 bits to get the value
    
    CMP.L   #%00, D5 ; Byte
    BEQ OPCODES_SHIFTING_SIZES_B
    
    CMP.L   #%01, D5 ; Word
    BEQ OPCODES_SHIFTING_SIZES_W
    
    CMP.L   #%10, D5 ; Long
    BEQ OPCODES_SHIFTING_SIZES_L
    
    BRA OPCODES_INVALID ; invalid size

OPCODES_SHIFTING_SIZES_B:
    MOVE.L  #1, D4
    BRA OPCODES_END

OPCODES_SHIFTING_SIZES_W:
    MOVE.L  #2, D4
    BRA OPCODES_END

OPCODES_SHIFTING_SIZES_L:
    MOVE.L  #3, D4
    BRA OPCODES_END


OPCODES_INVALID:  
    LEA Name_RawInvalid, A4
    MOVE.L  #0, D0 ; first byte
    JSR PUTHEX
    
    ADDA.L  #2, A4 ; move to the next location
    MOVE.L  #1, D0 ; second byte
    JSR PUTHEX
    
    ADDA.L  #2, A4 ; move to the next location
    MOVE.B  #0, (A4) ; null terminate
    
    MOVE.L  #0, D4 ; no size
    LEA Name_RawInvalid, A4 ; reset the pointer
    JSR IO_PRINT_OPCODES
    
    BRA OPCODES_END

OPCODES_END:
    MOVEM.L (SP)+, ALL_REG ; restore saved register state
    RTS ; return to IO

;
; Put two Hex value (as ASCII) at the specified index (D0) starting from A0
; into the WORD starting from A4. (each ASCII take 1 BYTE)
;
; Ex) Read 1 byte -> F5 -> 46 35 (string)
;
; Do not forget that the end of the string must be null terminated manually.
;
; Precondition:
;   A0 is pointing to the beginning of the array
;   D0.L is index value (A0 + this value)
;   A4 is pointing to the destination (does not depend on D0)
PUTHEX:
    MOVEM.L ALL_REG, -(SP)

    ADDA.L  D0, A0

    ; first hex
    MOVE.B (A0), D1
    AND.B   #$F0, D1 ; use first 4 bits
    LSR.B   #4, D1 ; shift right 4 bits to get the value
    JSR DIGIT_OR_ALPHA
    MOVE.B  D2, (A4)
    
    ADDA.L  #1, A4 ; advance one byte
    
    ; second hex
    MOVE.B (A0), D1 
    AND.B   #$0F, D1 ; use last 4 bits
    JSR DIGIT_OR_ALPHA
    MOVE.B  D2, (A4)
    
    MOVEM.L (SP)+, ALL_REG
    RTS

;
; Given the input Byte (D1), return the appropriate Hex character
;
; Precondition:
;   D1 >= 0 and D1 < 16
; Postcondition:
;   D2 contains the corresponding digit or alphabet
;   If D1 is out of range value, the D2 value is undefined
;
DIGIT_OR_ALPHA:
    CMP.B   #10, D1 ; digit or alphabet?
    BGE ALPHA
    BRA DIGIT
    
ALPHA:
    MOVE.B  D1, D2
    SUB.B   #10, D2
    ADD.B   #'A', D2
    RTS

DIGIT:
    MOVE.B  D1, D2
    ADD.B   #'0', D2
    RTS

* end of OpCodes


* start of EA
EFFECTIVEADDRESS:
    ; for sake of example, size is fixed to WORD
    ; and size will be stored in D7.B
    ; lets say 1 is BYTE, 2 is WORD, and 3 is LONG. 0 otherwise
    ; TODO: subject to change
    MOVE.B  #2, opcodeSize
    RTS
* end of EA

* end of program

    SIMHALT             ; halt simulator

* Put variables and constants here
opcodeSize  DS.L    1

Name_Move   DC.B    'MOVE',0
Name_Movea  DC.B    'MOVEA',0
Name_Nop    DC.B    'NOP',0
Name_Movem    DC.B    'MOVEM',0
Name_Lea    DC.B    'LEA',0
Name_Not    DC.B    'NOT',0
Name_Jsr    DC.B    'JSR',0
Name_Rts    DC.B    'RTS',0
Name_Addq    DC.B    'ADDQ',0
Name_Bgt    DC.B    'BGT',0
Name_Ble    DC.B    'BLE',0
Name_Beq    DC.B    'BEQ',0
Name_Bra    DC.B    'BRA',0
Name_Moveq    DC.B    'MOVEQ',0
Name_Or    DC.B    'OR',0
Name_Sub    DC.B    'SUB',0
Name_And    DC.B    'And',0
Name_Add    DC.B    'ADD',0
Name_Adda    DC.B    'ADDA',0
Name_Lsl    DC.B    'LSL',0
Name_Lsr    DC.B    'LSR',0
Name_Asl    DC.B    'ASL',0
Name_Asr    DC.B    'ASR',0
Name_Rol    DC.B    'ROL',0
Name_Ror    DC.B    'ROR',0
;Name_    DC.B    '',0 for copypasta
Name_RawInvalid DS.B    5 ; 4bytes for opcodes hex chars + 1 byte for null = 3

;TEST    DC.W    %0100111001110001 ; NOP
TEST    DC.W    %1111010101110001 ; invalid opcode test

END:
    END    START        ; last line of source












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
