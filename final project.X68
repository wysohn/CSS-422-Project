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
 
    CMP.B OPMOVE, D5 ; compare %00
    BNE OPCODES_OTHERS ; skip to other opcodes
    ; or continue to OPCODES_MOVE
    
OPCODES_MOVE: ; either MOVE or MOVEA
    ; TODO: get size (%00?? part)
    
    ; pass to EA to handle address
    ; MOVE or MOVEA will depend on the destination mode
    
    BRA OPCODES_END

OPCODES_OTHERS: ; any other OPCODES
    MOVE.B  (A0), D5
    AND.B #$F0, D5 ; extract 4 most significant bits out of 8 bits
    LSR.B #4, D5 ;shift 4 bits right to get the actual value
    
    CMP.B   OPSPECIAL, D5
    BEQ OPCODES_SPECIAL
    
    CMP.B   OPADDQ, D5
    BEQ OPCODES_ADDQ
    
    CMP.B   OPBRA, D5
    BEQ OPCODES_BRA

    CMP.B   OPMOVEQ, D5
    BEQ OPCODES_MOVEQ
    
    ;TODO: add more opcodes
    
    ; if code doesn't match with any, it's an invalid opcode
    BRA OPCODES_INVALID

OPCODES_SPECIAL:
    MOVE.W  (A0), D5
    AND.W #$0FFF, D5 ; use 12 least significant bits
    
    CMP.W   #%111,  D5 ; NOP, JSR, or RTS
    
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
