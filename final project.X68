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
    MOVE.W  #%0100111001110001, -(SP)
    MOVEA.L SP, A0
    
    JSR OPCODES
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
    BRA OPCODES_END

OPCODES_MOVEA:
    MOVE.L  #3, opcodeRef
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
    MOVE.L  #4, opcodeRef
    BRA OPCODES_END
    
OPCODES_SPECIAL_JSR:
    MOVE.L  #8, opcodeRef
    BRA OPCODES_END
    
OPCODES_SPECIAL_RTS:
    MOVE.L  #9, opcodeRef
    BRA OPCODES_END
    
OPCODES_SPECIAL_LEA:
    MOVE.L  #6, opcodeRef
    BRA OPCODES_END
    
OPCODES_SPECIAL_MOVEM:
    MOVE.L  #5, opcodeRef
    BRA OPCODES_END

OPCODES_SPECIAL_NOT:
    MOVE.L  #7, opcodeRef
    BRA OPCODES_END
    
OPCODES_ADDQ:

    BRA OPCODES_END
    
OPCODES_BRA:

    BRA OPCODES_END
    
OPCODES_MOVEQ:

    BRA OPCODES_END

; TODO: the rest of opcodes

OPCODES_INVALID:
    ;TODO: prepare invalid Hex (in D5)
    BRA OPCODES_END

OPCODES_END:
    MOVEM.L (SP)+, ALL_REG ; restore saved register state
    RTS ; return to IO
    
* end of OpCodes

* start of EA
EFFECTIVEADDRESS:
    ; for sake of example, size is fixed to WORD
    ; and size will be stored in D7.B
    ; lets say 1 is BYTE, 2 is WORD, and 3 is LONG. 0 otherwise
    ; TODO: subject to change
    MOVE.B  #2, D7
    RTS
* end of EA

* end of program

    SIMHALT             ; halt simulator

* Put variables and constants here

END:
    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
