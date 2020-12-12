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
    MOVE.L  #16, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

OPCODES_SUB:
    MOVE.L  #17, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
OPCODES_AND:
    MOVE.L  #18, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

OPCODES_ADD:
    MOVE.W  (A0), D5
    AND.W   #$0FFF, D5 ; use 12 least significant bits
    LSR.W   #6, D6 ; shift right 6 bits to get 6 MSB
    AND.W   #$0007, D6 ; interested only in last 3 bits
    
    CMP.W   #%001,  D6 ; is dest mode 001? then it is ADDA, or else, ADD
    BEQ     OPCODES_ADDA
    
    MOVE.L  #19, opcodeRef
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

OPCODES_ADDA:
    MOVE.L  #20, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
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
    BRA OPCODES_ADD_SIZES_END

OPCODES_ADD_SIZES_W:
    MOVE.L  #2, D4
    BRA OPCODES_ADD_SIZES_END

OPCODES_ADD_SIZES_L:
    MOVE.L  #3, D4
    BRA OPCODES_ADD_SIZES_END

OPCODES_ADD_SIZES_END:
    LEA Name_Move, A4
    JSR IO_PRINT_OPCODES ; A4 pointing to the op name, D4 contains op size
    JSR EFFECTIVEADDRESS
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
    
    MOVE.L  #22, opcodeRef ; otherwise, it's LSR
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
OPCODES_ASL:
    MOVE.L  #23, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

OPCODES_ASR:
    MOVE.L  #24, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

OPCODES_ROL:
    MOVE.L  #25, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END

OPCODES_ROR:
    MOVE.L  #26, opcodeRef 
    JSR EFFECTIVEADDRESS
    BRA OPCODES_END
    
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
    BRA OPCODES_SHIFTING_SIZES_END

OPCODES_SHIFTING_SIZES_W:
    MOVE.L  #2, D4
    BRA OPCODES_SHIFTING_SIZES_END

OPCODES_SHIFTING_SIZES_L:
    MOVE.L  #3, D4
    BRA OPCODES_SHIFTING_SIZES_END

OPCODES_SHIFTING_SIZES_END:
    LEA Name_Move, A4
    JSR IO_PRINT_OPCODES ; A4 pointing to the op name, D4 contains op size
    JSR EFFECTIVEADDRESS
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
          MOVE.L (A0),D3
         MOVEA A0,A5 ;Used for print(xxx).L/(xxx).W/#Immediates
       ; MOVE.L #8,opcodeRef   ;for Testing opcodeRef entries
         MOVE.L #1,D2          ;Counter for comparisons
         ADD.B #16,numberBits
        
           
         
         CMP.L  opcodeRef,D2           
         BEQ    MoveMovea
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    MoveEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    MoveaEA
         ADDQ.B #1,D2

         CMP.L  opcodeRef,D2           
         BEQ    NopEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    MovemEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    LeaEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    NotEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    JsrEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    RtsEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    AddqEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    BgtEA
         ADDQ.B #1,D2

         CMP.L  opcodeRef,D2           
         BEQ    BleEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    BeqEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    BraEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    MoveqEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2   ;OR     ;First compare the opcode value to branch to proper EA decoding section
         BEQ    decSec3
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2   ;SUB        
         BEQ    decSec3
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2    ;AND       
         BEQ    decSec3
         ADDQ.B #1,D2
         
         CMP.L  opcodeRef,D2    ;ADD       
         BEQ    decSec3
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2   ;ADDA        
         BEQ    decSec3
         ADDQ.B #1,D2
     
         CMP.L  opcodeRef,D2  ;LSL           
         BEQ    decSec4 
         ADDQ.B #1,D2  
         
         CMP.L  opcodeRef,D2  ;LSR        
         BEQ    decSec4
         ADDQ.B #1,D2 
         
         CMP.L  opcodeRef,D2  ;ASL         
         BEQ    decSec4
         ADDQ.B #1,D2 
         
         CMP.L  opcodeRef,D2  ;ASR      
         BEQ    decSec4
         ADDQ.B #1,D2 
         
         CMP.L  opcodeRef,D2  ;ROL         
         BEQ    decSec4
         ADDQ.B #1,D2 
         
         CMP.L  opcodeRef,D2 ;ROR          
         BEQ    decSec4
         BRA    end
         ;NEED TO ADD THE OTHER OPCODES STILL
         
decSec3  LSL.L #4,D3   ;gets rid of first 4 bits
         MOVE.L #1,D2
         
sec3Loop  LSL.L #1,D3    ;gets 1st reg# and stores it in D4
         BCS   sec3Loop1
         LSL.L  #1,D4
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetD2
         BRA   sec3Loop
         
 
sec3Loop1 LSL.L  #1,D4
         ADD.B #%1,D4
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetD2
         BRA   sec3Loop

resetD2 MOVE.B #$01,D2

sec3Loop2 LSL.L #1,D3    ;gets opmode and stores it in D5
         BCS   sec3Loop3
         LSL.L  #1,D5
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetD2
         BRA   sec3Loop2
         
 
sec3Loop3 LSL.L  #1,D5
         ADD.B #%1,D5
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetD2
         BRA   sec3Loop2
         
resetsetD2 MOVE.B #$01,D2

sec3Loop4 LSL.L #1,D3    ;gets ea mode and stores it in D1
         BCS   sec3Loop5
         LSL.L  #1,D1
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetD2
         BRA   sec3Loop4
         
 
sec3Loop5 LSL.L  #1,D1
         ADD.B #%1,D1
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetD2
         BRA   sec3Loop4

resetsetsetD2 MOVE.B #$01,D2

sec3Loop6 LSL.L #1,D3    ;gets ea mode and stores it in D7
         BCS   sec3Loop7
         LSL.L  #1,D7
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   nextSec3
         BRA   sec3Loop6
         
 
sec3Loop7 LSL.L  #1,D7
         ADD.B #%1,D7
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   nextSec3
         BRA   sec3Loop6

nextSec3  MOVE.W #16,D2

         CMP.L  opcodeRef,D2   ;OR     ;First compare the opcode value to branch to proper EA decoding section
         BEQ    OrEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2   ;SUB        
         BEQ    SubEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2    ;AND       
         BEQ    AndEA
         ADDQ.B #1,D2
         
         CMP.L  opcodeRef,D2    ;ADD       
         BEQ    AddEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2   ;ADDA        
         BEQ    AddaEA
         BRA    end


;----------------------------------------------------Section 4: Decodes and prints ASL,ASR,ROL,ROR,LSL,LSR--------------------         
decSec4  LSL.L #4,D3   ;gets rid of first 4 bits
         MOVE.L #1,D2
         
sec4Loop  LSL.L #1,D3    ;gets 1st reg# and stores it in D4
         BCS   sec4Loop1
         LSL.L  #1,D4
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ    resetD24
         BRA   sec4Loop
         
 
sec4Loop1 LSL.L  #1,D4
         ADD.B #%1,D4
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ    resetD24
         BRA   sec4Loop

resetD24 MOVE.B #$01,D2
         LSL.L #1,D3

sec4Loop2 LSL.L #1,D3    ;gets size and stores it in D5
         BCS   sec4Loop3
         LSL.L  #1,D5
     
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetsetD24
         BRA   sec4Loop2
         
 
sec4Loop3 LSL.L  #1,D5
         ADD.B #%1,D5
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetsetD24
         BRA   sec4Loop2
         
resetsetD24 MOVE.B #$01,D2

sec4Loop4 LSL.L #1,D3    ;gets i/r and stores it in D6
         BCS   sec4Loop5
         LSL.L  #1,D6
     
         ADDQ.B #1,D2
         CMP.B  #2,D2
         BEQ   resetsetsetD24
         BRA   sec4Loop4
         
 
sec4Loop5 LSL.L  #1,D6
         ADD.B #%1,D6
         ADDQ.B #1,D2
         CMP.B  #2,D2
         BEQ   resetsetsetD24
         BRA   sec4Loop4


;Add bit that is in D6, then sotre next two bits for Address mode if there is an An

resetsetsetD24 MOVE.B #$01,D2
               MOVE.B D6,D1

sec4Loop6 LSL.L #1,D3    ;twobits plus extra for address mode if needed it in D1
         BCS   sec4Loop7
         LSL.L  #1,D1
     
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetsetsetsetD24
         BRA   sec4Loop6
         
 
sec4Loop7 LSL.L  #1,D1
         ADD.B #%1,D1
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetsetsetsetD24
         BRA   sec4Loop6
         
resetsetsetsetD24 MOVE.B #$01,D2
         
sec4Loop8 LSL.L #1,D3     ;gets reg and stores it in D7
         BCS   sec4Loop9
         LSL.L  #1,D7
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   nextSec4
         BRA   sec4Loop8
         
 
sec4Loop9 LSL.L  #1,D7
         ADD.B #%1,D7
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   nextSec4
         BRA   sec4Loop8

nextSec4  CMP.B #%11, D5   ;Compare Size to 11: if 11 then it is a memory shift; if it is not it is a Dn shift
          BEQ   sec4An
          CMP.B #%1,D6
          BEQ   sec4Dreg
          CMP.B #0,D4
          BEQ   sec4pound8
          CMP.B #1,D4
          BEQ   sec4pound1
          CMP.B #2,D4
          BEQ   sec4pound2
          CMP.B #3,D4
          BEQ   sec4pound3
          CMP.B #4,D4
          BEQ   sec4pound4
          CMP.B #5,D4
          BEQ   sec4pound5
          CMP.B #6,D4
          BEQ   sec4pound6
          CMP.B #7,D4
          BEQ   sec4pound7
          BRA   end
          
sec4pound8 LEA     p00,A1 
           MOVE.B  #14,D0
           TRAP    #15    
           BRA     sec4printDn      
sec4pound1 LEA     p1,A1 
           MOVE.B  #14,D0
           TRAP    #15 
           BRA     sec4printDn 
sec4pound2 LEA     p2,A1 
           MOVE.B  #14,D0
           TRAP    #15
           BRA     sec4printDn 
sec4pound3 LEA     p3,A1 
           MOVE.B  #14,D0
           TRAP    #15
           BRA     sec4printDn 
sec4pound4 LEA     p4,A1 
           MOVE.B  #14,D0
           TRAP    #15
           BRA     sec4printDn 
sec4pound5 LEA     p5,A1 
           MOVE.B  #14,D0
           TRAP    #15
           BRA     sec4printDn 
sec4pound6 LEA     p6,A1 
           MOVE.B  #14,D0
           TRAP    #15
           BRA     sec4printDn 
sec4pound7 LEA     p7,A1 
           MOVE.B  #14,D0
           TRAP    #15
           BRA     sec4printDn           

sec4Dreg    CMP.B #%000,D4
            BEQ   sec4Dr0
            CMP.B #%001,D4
            BEQ   sec4Dr1
            CMP.B #%010,D4
            BEQ   sec4Dr2
            CMP.B #%011,D4
            BEQ   sec4Dr3
            CMP.B #%100,D4
            BEQ   sec4Dr4
            CMP.B #%101,D4
            BEQ   sec4Dr5
            CMP.B #%110,D4
            BEQ   sec4Dr6
            CMP.B #%111,D4
            BEQ   sec4Dr7


sec4Dr0      LEA     Dn0,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4printDn
sec4Dr1      LEA     Dn1,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4printDn
sec4Dr2      LEA     Dn2,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4printDn
sec4Dr3      LEA     Dn3,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4printDn
sec4Dr4      LEA     Dn4,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4printDn
sec4Dr5      LEA     Dn5,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4printDn
sec4Dr6      LEA     Dn6,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4printDn
sec4Dr7      LEA     Dn7,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4printDn            
       
          ;then print Dn of number in reg at the end
          ;This solves: LSL,LSR,ASL,ASR,ROR, and ROL
          
          ;If An shift just check mode and reg then print
          
sec4printDn LEA     comma,A1 
            MOVE.B  #14,D0
            TRAP    #15

            CMP.B #%000,D7
            BEQ   sec4D0
            CMP.B #%001,D7
            BEQ   sec4D1
            CMP.B #%010,D7
            BEQ   sec4D2
            CMP.B #%011,D7
            BEQ   sec4D3
            CMP.B #%100,D7
            BEQ   sec4D4
            CMP.B #%101,D7
            BEQ   sec4D5
            CMP.B #%110,D7
            BEQ   sec4D6
            CMP.B #%111,D7
            BEQ   sec4D7
            
sec4D0      LEA     Dn0,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     end
sec4D1      LEA     Dn1,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     end
sec4D2      LEA     Dn2,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     end
sec4D3      LEA     Dn3,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     end
sec4D4      LEA     Dn4,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     end
sec4D5      LEA     Dn5,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     end
sec4D6      LEA     Dn6,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     end
sec4D7      LEA     Dn7,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     end   
         
sec4An      CMP.B #%000,D1
            BEQ   printError
            CMP.B #%001,D1
            BEQ printError
            CMP.B #%010,D1  ;Normal (An)
            BEQ   sec4parAn
            CMP.B #%011,D1  ;(An)+
            BEQ   sec4parAn 
            CMP.B #%100,D1  ;-(An)
            BEQ   sec4negAn
            CMP.B #%111,D1
            BEQ   sec4EA
            
            
sec4parAn   LEA     parStart,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4PrintAn
sec4negAn   LEA     parNegStart,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4PrintAn
            
sec4printAn CMP.B #%000,D7
            BEQ   sec4A0
            CMP.B #%001,D7
            BEQ   sec4A1
            CMP.B #%010,D7
            BEQ   sec4A2
            CMP.B #%011,D7
            BEQ   sec4A3
            CMP.B #%100,D7
            BEQ   sec4A4
            CMP.B #%101,D7
            BEQ   sec4A5
            CMP.B #%110,D7
            BEQ   sec4A6
            CMP.B #%111,D7
            BEQ   sec4A7
            
sec4A0      LEA     An0,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4parEnd
sec4A1      LEA     An1,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4parEnd
sec4A2      LEA     An2,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4parEnd
sec4A3      LEA     An3,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4parEnd
sec4A4      LEA     An4,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4parEnd
sec4A5      LEA     An5,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4parEnd
sec4A6      LEA     An6,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4parEnd
sec4A7      LEA     An7,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     sec4parEnd    
            
sec4parEnd  CMP.B #%010,D1  ;Normal (An)
            BEQ   sec4parEndAn
            CMP.B #%011,D1  ;(An)+
            BEQ   sec4posEndAn 
            CMP.B #%100,D1  ;-(An)
            BEQ   sec4parEndAn
            
sec4parEndAn   LEA     parEnd,A1 
               MOVE.B  #14,D0
               TRAP    #15
               BRA     end
sec4posEndAn   LEA     parPosEnd,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     end ;remeber bitcount for i/o
            
     ;Merge these two sections of moving data, then just move word for word and move long for long
sec4EA     MOVE.L #$00000000,D2
           MOVEA A0,A5
           ADDA #16,A5
           MOVE.L (A5),D3


sec4addval   CMP.B #%000,D7
            BEQ   sec4Word
            CMP.B #%001,D7
            BEQ   sec4Long
            BRA   printError
sec4Word    MOVE.W (A5),D2  ;ask about******************
            ADD.W #16,numberBits 
            BRA    sec4Print

sec4Long    MOVE.L  (A5),D2
            ADD.W #32,numberBits 

sec4Print   LEA     money,A1 
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.L  D2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            BRA     end
            
;Just needs to be tested with other code----------------------------------------------------------------------------------------------------
            
   
MoveMovea LSL.L #2,D3   ;gets rid of first 4 bits
         MOVE.L #1,D2
         
sec1Loop  LSL.L #1,D3    ;gets size in D4
         BCS   sec1Loop1
         LSL.L  #1,D4
     
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetD21
         BRA   sec1Loop
         
 
sec1Loop1 LSL.L  #1,D4
         ADD.B #%1,D4
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetD21
         BRA   sec1Loop

resetD21 MOVE.B #$01,D2

sec1Loop2 LSL.L #1,D3    ;gets destination register in D5
         BCS   sec1Loop3
         LSL.L  #1,D5
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetD21
         BRA   sec1Loop2
         
 
sec1Loop3 LSL.L  #1,D5
         ADD.B #%1,D5
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetD21
         BRA   sec1Loop2
         
resetsetD21 MOVE.B #$01,D2

sec1Loop4 LSL.L #1,D3    ;gets destination mode in D6
         BCS   sec1Loop5
         LSL.L  #1,D6
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetD21
         BRA   sec1Loop4
         
 
sec1Loop5 LSL.L  #1,D6
         ADD.B #%1,D6
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetD21
         BRA   sec1Loop4

resetsetsetD21 MOVE.B #$01,D2

sec1Loop6 LSL.L #1,D3    ;gets ea source mode stores it in D1
         BCS   sec1Loop7
         LSL.L  #1,D1
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetsetD21
         BRA   sec1Loop6
         
 
sec1Loop7 LSL.L  #1,D1
         ADD.B #%1,D1
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetsetD21
         BRA   sec1Loop6
         
         
resetsetsetsetD21 MOVE.B #$01,D2

sec1Loop8 LSL.L #1,D3    ;gets ea source register stores it in D7
         BCS   sec1Loop9
         LSL.L  #1,D7
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   nextSec1
         BRA   sec1Loop8
         
 
sec1Loop9 LSL.L  #1,D7
         ADD.B #%1,D7
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   nextSec1
         BRA   sec1Loop8

 
nextSec1  CMP.B #%001,D6
          BEQ   MoveaEA
          BRA   MoveEA
          BRA   printError
          
MoveEA    LEA     MOVEE,A1 
          MOVE.B  #14,D0
          TRAP    #15
          CMP.B  #%01,D4
          BEQ    moveB
          CMP.B  #%11,D4
          BEQ    moveW
          CMP.B  #%10,D4
          BEQ    moveL
moveL     LEA     longOp,A1 
          MOVE.B  #14,D0
          TRAP    #15
          MOVE.B D4,(A6)
          BRA     printMove
moveW     LEA     wordOp,A1 
          MOVE.B  #14,D0
          TRAP    #15
          MOVE.B D4,(A6)
          BRA     printMove
moveB     LEA     byteOp,A1 
          MOVE.B  #14,D0
          TRAP    #15    
          MOVE.B D4,(A6)

printMove JSR     printEA
          LEA     comma,A1 
          MOVE.B  #14,D0
          TRAP    #15  
          
          MOVE.L  D6,D1 ;sets up next printEA call with destination data
          MOVE.L  D5,D7
          CMP.B   #%111,D6
          BEQ     checkIm
          JSR     printEA
          BRA     end
          
checkIm   CMP.B  #%100,D7
          BEQ    printError
          JSR    printEA 
          BRA    end       

MoveaEA   LEA     MOVEA,A1 
          MOVE.B  #14,D0
          TRAP    #15
          CMP.B  #%11,D4
          BEQ    moveWa
          CMP.B  #%10,D4
          BEQ    moveLa
moveLa     LEA     longOp,A1 
          MOVE.B  #14,D0
          TRAP    #15
          MOVE.B D4,(A6)
          BRA     printMovea
moveWa    LEA     wordOp,A1 
          MOVE.B  #14,D0
          TRAP    #15
          MOVE.B D4,(A6)
          BRA     printMovea
          
printMovea JSR     printEA
          LEA     comma,A1 
          MOVE.B  #14,D0
          TRAP    #15  
          
          MOVE.L  D6,D1 ;sets up next printEA call with destination data
          MOVE.L  D5,D7
          JSR     printEA
          BRA     end          

NopEA    BRA end

MovemEA

LeaEA    LSL.L #4,D3   ;gets rid of first 4 bits
         MOVE.L #1,D2
         
LeaLoop  LSL.L #1,D3    ;gets destination An reg# and stores it in D4
         BCS   LeaLoop1
         LSL.L  #1,D4
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetLD2
         BRA   LeaLoop
         
 
LeaLoop1 LSL.L  #1,D4
         ADD.B #%1,D4
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetLD2
         BRA   LeaLoop

resetLD2 MOVE.B #$01,D2

LeaLoop2 LSL.L #1,D3    ;gets number to check for error it in D5. should be %111
         BCS   LeaLoop3
         LSL.L  #1,D5
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetLD2
         BRA   LeaLoop2
         
 
LeaLoop3 LSL.L  #1,D5
         ADD.B #%1,D5
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetLD2
         BRA   LeaLoop2
         
resetsetLD2 MOVE.B #$01,D2

LeaLoop4 LSL.L #1,D3    ;gets ea mode and stores it in D1
         BCS   LeaLoop5
         LSL.L  #1,D1
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetLD2
         BRA   LeaLoop4
         
 
LeaLoop5 LSL.L  #1,D1
         ADD.B #%1,D1
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetLD2
         BRA   LeaLoop4

resetsetsetLD2 MOVE.B #$01,D2

LeaLoop6 LSL.L #1,D3    ;gets ea register stores it in D7
         BCS   LeaLoop7
         LSL.L  #1,D7
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   LeaCheck ;MAKE SURE TO UPDATE IT CODE--------------------------------------------------------------------------------------------------------
         BRA   LeaLoop6
         
 
LeaLoop7 LSL.L  #1,D7
         ADD.B #%1,D7
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   LeaCheck
         BRA   LeaLoop6

LeaCheck CMP.B #%111,D5
         BEQ   LeaTest1
         BRA   printError
LeaTest1 CMP.B #%010,D1
         BEQ   LeaPrint
         CMP.B #%111,D1
         BEQ   LeaTest2 
         BRA   printError       
LeaTest2 CMP.B #%000,D7    ;Means source is a (xxx).W
         BEQ   LeaPrint
         CMP.B #%001,D7
         BEQ   LeaPrint
         BRA   printError
         
LeaPrint  JSR     printEA
          LEA     comma,A1 
          MOVE.B  #14,D0
          TRAP    #15  
          
          MOVE.L  #%001,D1 ;sets up next printEA call with destination data
          MOVE.L  D4,D7
          JSR     printEA
          BRA     end    

NotEA    MOVE.L #1,D2
         
NotLoop  LSL.L #1,D3    ;gets first 8 bits for testing and stores it in D4
         BCS   NotLoop1
         LSL.L  #1,D4
     
         ADDQ.B #1,D2
         CMP.B  #9,D2
         BEQ   resetND2
         BRA   NotLoop
         
 
NotLoop1 LSL.L  #1,D4
         ADD.B #%1,D4
         ADDQ.B #1,D2
         CMP.B  #9,D2
         BEQ   resetND2
         BRA   NotLoop

resetND2 MOVE.B #$01,D2

NotLoop2 LSL.L #1,D3    ;gets size and stores it in D5
         BCS   NotLoop3
         LSL.L  #1,D5
     
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetsetND2
         BRA   NotLoop2
         
 
NotLoop3 LSL.L  #1,D5
         ADD.B #%1,D5
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetsetND2
         BRA   NotLoop2
         
resetsetND2 MOVE.B #$01,D2
            MOVE.L D5,(A6)

NotLoop4 LSL.L #1,D3    ;gets ea mode and stores it in D1
         BCS   NotLoop5
         LSL.L  #1,D1
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetND2
         BRA   NotLoop4
         
 
NotLoop5 LSL.L  #1,D1
         ADD.B #%1,D1
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetND2
         BRA   NotLoop4

resetsetsetND2 MOVE.B #$01,D2

NotLoop6 LSL.L #1,D3    ;gets ea register stores it in D7
         BCS   NotLoop7
         LSL.L  #1,D7
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   NotCheck
         BRA   NotLoop6
         
 
NotLoop7 LSL.L  #1,D7
         ADD.B #%1,D7
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   NotCheck
         BRA   NotLoop6
NotCheck CMP.B #%01000110,D4 
         BEQ   NotTest
         BRA   printError
NotTest  CMP.B #%001,D1
         BEQ   printError
         CMP.B #%111,D1
         BEQ   NotTest1
         BRA   NotPrint  
NotTest1 CMP.B #%100,D7    ;Means source is a (xxx).W
         BEQ   printError   ;CURRENT SPOT=------------------------------------------------------------------------------
         
NotPrint  JSR     printEA   
          RTS

JsrEA    LSL.L #8,D3   ;gets rid of first 4 bits
         LSL.L #2,D3
         MOVE.L #1,D2
         
JsrLoop  LSL.L #1,D3    ;gets mode and stores in D1
         BCS   JsrLoop1
         LSL.L  #1,D1
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetjD2
         BRA   JsrLoop
         
 
JsrLoop1 LSL.L  #1,D1
         ADD.B #%1,D1
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetjD2
         BRA   JsrLoop

resetjD2 MOVE.B #$01,D2

JsrLoop2 LSL.L #1,D3    ;gets register # and stores it in D7
         BCS   JsrLoop3
         LSL.L  #1,D7
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   JsrTest
         BRA   JsrLoop2
         
 
JsrLoop3 LSL.L  #1,D7
         ADD.B #%1,D7
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   JsrTest
         BRA   JsrLoop2
JsrTest  CMP.B #%010,D1
         BEQ   JsrPrint
         CMP.B #%111,D1
         BEQ   JsrTest2
         BRA   printError
JsrTest2 CMP.B #%000,D7
         BEQ   JsrW
         CMP.B #%001,D7
         BEQ   JsrL
         BRA   printError
JsrW     MOVE.B #%11,(A6)
         BRA   printEA
JsrL     MOVE.B #%10,(A6)         
JsrPrint JSR printEA
         RTS

RtsEA   BRA end

AddqEA   LSL.L #4,D3   ;gets rid of first 4 bits
         MOVE.L #1,D2
         
addqLoop  LSL.L #1,D3    ;gets data stores it in D4
         BCS   addqLoop1
         LSL.L  #1,D4
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetqD2
         BRA   addqLoop
         
 
addqLoop1 LSL.L  #1,D4
         ADD.B #%1,D4
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetqD2
         BRA   addqLoop

resetqD2 MOVE.B #$01,D2
         LSL.L  #1,D3

addqLoop2 LSL.L #1,D3    ;get size and place in D5
         BCS   addqLoop3
         LSL.L  #1,D5
     
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetsetqD2
         BRA   addqLoop2
         
 
addqLoop3 LSL.L  #1,D5
         ADD.B #%1,D5
         ADDQ.B #1,D2
         CMP.B  #3,D2
         BEQ   resetsetqD2
         BRA   addqLoop2
         
resetsetqD2 MOVE.B #$01,D2
            MOVE.B D5,(A6)

addqLoop4 LSL.L #1,D3    ;gets ea mode and stores it in D1
         BCS   addqLoop5
         LSL.L  #1,D1
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetqD2
         BRA   addqLoop4
         
 
addqLoop5 LSL.L  #1,D1
         ADD.B #%1,D1
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetqD2
         BRA   addqLoop4

resetsetsetqD2 MOVE.B #$01,D2

addqLoop6 LSL.L #1,D3    ;gets ea register stores it in D7
         BCS   addqLoop7
         LSL.L  #1,D7
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   AddqCheck 
         BRA   addqLoop6
         
 
addqLoop7 LSL.L  #1,D7
         ADD.B #%1,D7
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   AddqCheck
         BRA   addqLoop6

AddqCheck CMP.B #%000,D4
          BEQ   qp8
          CMP.B #%001,D4
          BEQ   qp1
          CMP.B #%010,D4
          BEQ   qp2
          CMP.B #%011,D4
          BEQ   qp3
          CMP.B #%100,D4
          BEQ   qp4
          CMP.B #%101,D4
          BEQ   qp5
          CMP.B #%110,D4
          BEQ   qp6
          CMP.B #%111,D4
          BEQ   qp7
         
qp8       LEA     p00,A1 
          MOVE.B  #14,D0
          TRAP    #15
          BRA     AddQPrint
qp1       LEA     p1,A1 
          MOVE.B  #14,D0
          TRAP    #15
          BRA     AddQPrint
qp2       LEA     p2,A1 
          MOVE.B  #14,D0
          TRAP    #15
          BRA     AddQPrint
qp3       LEA     p3,A1 
          MOVE.B  #14,D0
          TRAP    #15  
          BRA     AddQPrint
qp4       LEA     p4,A1 
          MOVE.B  #14,D0
          TRAP    #15
          BRA     AddQPrint
qp5       LEA     p5,A1 
          MOVE.B  #14,D0
          TRAP    #15
          BRA     AddQPrint
qp6       LEA     p6,A1 
          MOVE.B  #14,D0
          TRAP    #15
          BRA     AddQPrint
qp7       LEA     p7,A1 
          MOVE.B  #14,D0
          TRAP    #15
         
AddQPrint LEA     comma,A1 
          MOVE.B  #14,D0
          TRAP    #15 
          JSR     printEA   ;finish checkssss
          BRA     end    


BgtEA

BleEA    

BeqEA

BraEA

MoveqEA

;---------------------------------Section 3: OR,SUB,ADD,ADDA,AND-------------------------------------------------------

OrEA     
         
SubEA   
         
AndEA   

AddEA CMP.B #%000,D5 ;Byte
      BEQ   DnDestB
      CMP.B #%001,D5 ;Word
      BEQ   DnDestW
      CMP.B #%010,D5 ;Long These three are if Dn is the destination
      BEQ   DnDestL
      CMP.B #%100,D5 ;Byte
      BEQ   DnSrcB
      CMP.B #%0101,D5 ;Word
      BEQ   DnSrcW
      CMP.B #%110,D5 ;Long These three are if Dn is the src
      BEQ   DnSrcL
      
DnDestB  MOVE.B #%01,(A6)
         BRA    DnDest
DnDestW  MOVE.B #%11,(A6)
         BRA    DnDest
DnDestL  MOVE.B #%10,(A6)

DnDest  JSR printEA
        LEA     comma,A1 
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B D4,D7
        MOVE.B #%0000,D1
        JSR printEA
        RTS

DnSrcB MOVE.B #%01,(A6)
       BRA    DnTest
DnSrcW MOVE.B #%11,(A6)
       BRA    DnTest
DnSrcL MOVE.B #%10,(A6)

DnTest CMP.B #%000,D1
       BEQ   printError
       CMP.B #%001,D1
       BEQ   printError
       CMP.B #%111,D1
       BEQ   DnTest1
       BRA   DnSrc
DnTest1 CMP.B #%100,D7
        BEQ   printError      

DnSrc CMP.B #%000,D4
      BEQ   DnSrc0
      CMP.B #%001,D4
      BEQ   DnSrc1
      CMP.B #%010,D4
      BEQ   DnSrc2
      CMP.B #%011,D4
      BEQ   DnSrc3
      CMP.B #%100,D4
      BEQ   DnSrc4
      CMP.B #%101,D4
      BEQ   DnSrc5
      CMP.B #%110,D4
      BEQ   DnSrc6
      CMP.B #%111,D4
      BEQ   DnSrc7


DnSrc0 LEA     Dn0,A1 
      MOVE.B  #14,D0
      TRAP    #15
      BRA SrcSec
DnSrc1 LEA     Dn1,A1 
      MOVE.B  #14,D0
      TRAP    #15
      BRA SrcSec
DnSrc2 LEA     Dn2,A1 
      MOVE.B  #14,D0
      TRAP    #15
      BRA SrcSec
DnSrc3 LEA     Dn3,A1 
      MOVE.B  #14,D0
      TRAP    #15
      BRA SrcSec
DnSrc4 LEA     Dn4,A1 
       MOVE.B  #14,D0
       TRAP    #15
       BRA SrcSec
DnSrc5 LEA     Dn5,A1 
      MOVE.B  #14,D0
      TRAP    #15
      BRA SrcSec
DnSrc6 LEA     Dn6,A1 
      MOVE.B  #14,D0
      TRAP    #15
      BRA SrcSec
DnSrc7 LEA     Dn7,A1 
      MOVE.B  #14,D0
      TRAP    #15
      BRA SrcSec
      
SrcSec LEA     comma,A1 
       MOVE.B  #14,D0
       TRAP    #15
       JSR printEA
       RTS

AddaEA       
         
printEA     MOVE.L #$00000000,D2
            CMP.B #%000,D1
            BEQ   printDn
            CMP.B #%001,D1
            BEQ   printMiddleAn
            CMP.B #%010,D1  ;Normal (An)
            BEQ   parAn
            CMP.B #%011,D1  ;(An)+
            BEQ   parAn 
            CMP.B #%100,D1  ;-(An)
            BEQ   negAn
            CMP.B #%111,D1
            BEQ   printOtherEA

printDn     CMP.B #%000,D7
      BEQ   printDn0
      CMP.B #%001,D7
      BEQ   printDn1
      CMP.B #%010,D7
      BEQ   printDn2
      CMP.B #%011,D7
      BEQ   printDn3
      CMP.B #%100,D7
      BEQ   printDn4
      CMP.B #%101,D7
      BEQ   printDn5
      CMP.B #%110,D7
      BEQ   printDn6
      CMP.B #%111,D7
      BEQ   printDn7


printDn0 LEA     Dn0,A1 
      MOVE.B  #14,D0
      TRAP    #15
      RTS
printDn1 LEA     Dn1,A1 
      MOVE.B  #14,D0
      TRAP    #15
      RTS
printDn2 LEA     Dn2,A1 
      MOVE.B  #14,D0
      TRAP    #15
      RTS
printDn3 LEA     Dn3,A1 
      MOVE.B  #14,D0
      TRAP    #15
      RTS
printDn4 LEA     Dn4,A1 
       MOVE.B  #14,D0
       TRAP    #15
       RTS
printDn5 LEA     Dn5,A1 
      MOVE.B  #14,D0
      TRAP    #15
      RTS
printDn6 LEA     Dn6,A1 
      MOVE.B  #14,D0
      TRAP    #15
      RTS
printDn7 LEA     Dn7,A1 
      MOVE.B  #14,D0
      TRAP    #15
      RTS


parAn       LEA     parStart,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     printMiddleAn
negAn       LEA     parNegStart,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     printMiddleAn
            
printMiddleAn CMP.B #%000,D7 ;check registers to use right reg
            BEQ   printA0
            CMP.B #%001,D7
            BEQ   printA1
            CMP.B #%010,D7
            BEQ   printA2
            CMP.B #%011,D7
            BEQ   printA3
            CMP.B #%100,D7
            BEQ   printA4
            CMP.B #%101,D7
            BEQ   printA5
            CMP.B #%110,D7
            BEQ   printA6
            CMP.B #%111,D7
            BEQ   printA7
            
printA0      LEA     An0,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     parEndprint
printA1      LEA     An1,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     parEndprint
printA2      LEA     An2,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     parEndprint
printA3      LEA     An3,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     parEndprint
printA4      LEA     An4,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     parEndprint
printA5      LEA     An5,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     parEndprint
printA6      LEA     An6,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     parEndprint
printA7      LEA     An7,A1 
            MOVE.B  #14,D0
            TRAP    #15
            BRA     parEndprint   
            
parEndprint CMP.B #%010,D1  ;Normal (An)
            BEQ   parEndAn
            CMP.B #%011,D1  ;(An)+
            BEQ   posEndAn 
            CMP.B #%100,D1  ;-(An)
            BEQ   parEndAn
            CMP.B #001,D1    ;just An
            RTS
parEndAn       LEA     parEnd,A1 
               MOVE.B  #14,D0
               TRAP    #15
               RTS
posEndAn   LEA     parPosEnd,A1 
            MOVE.B  #14,D0
            TRAP    #15
            RTS ;remeber bitcount for i/o
 
printOtherEA     MOVE.L #$00000000,D2
                 ADDA #16,A5
                 MOVE.L (A5),D3


addval      CMP.B #%000,D7
            BEQ   printWord
            CMP.B #%001,D7
            BEQ   printLong
            CMP.B #%100,D7
            BEQ   printImmediateHex
            BRA   printError
printWord   MOVE.W (A5),D2  ;ask about******************
            ADD.W  #16,numberBits
            BRA    finalPrint

printLong   MOVE.L  (A5),D2
            ADD.W #32,numberBits 

finalPrint   LEA     money,A1 
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.L  D2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            RTS
            
printImmediateHex   ADDA  #16,A5
                    CMP.B #%01,(A6) ;Byte
                    BEQ   imByte
                    CMP.B #%11,(A6)  ;Word
                    BEQ   imWord   
                    CMP.B #%10,(A6)  ;Long
                    BEQ   imLong       
imByte      MOVE.B (A5),D2
            ADD.B  #8,numberBits
            LEA     pound,A1 
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.L  D2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            RTS
            
imWord      MOVE.W (A5),D2
            ADD.B  #16,numberBits
            LEA     pound,A1 
            MOVE.B  #14,D0
            TRAP    #15
            LEA     money,A1 
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.L  D2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            RTS
            
imLong      MOVE.L (A5),D2
            ADD.B  #32,numberBits
            LEA     pound,A1 
            MOVE.B  #14,D0
            TRAP    #15
            LEA     money,A1 
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.L  D2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            RTS
            
printError LEA     errorM,A1 
           MOVE.B  #14,D0
           TRAP    #15
           BRA   end

end   LEA     EndBRA,A1 
      MOVE.B  #14,D0
      TRAP    #15
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

EndBRA  DC.B 'End',CR,LF,0
Dn0     DC.B 'D0',0
Dn1     DC.B 'D1',0
Dn2     DC.B 'D2',0
Dn3     DC.B 'D3',0
Dn4     DC.B 'D4',0
Dn5     DC.B 'D5',0
Dn6     DC.B 'D6',0
Dn7     DC.B 'D7',0

An0     DC.B 'A0',0
An1     DC.B 'A1',0
An2     DC.B 'A2',0
An3     DC.B 'A3',0
An4     DC.B 'A4',0
An5     DC.B 'A5',0
An6     DC.B 'A6',0
An7     DC.B 'A7',0

parNegStart DC.B '-(',0
parStart    DC.B '(',0
parPosEnd DC.B ')+',0
parEnd   DC.B ')',0


p00          DC.B '#8',0
p0           DC.B '#0',0
p1          DC.B '#1',0
p2          DC.B '#2',0
p3          DC.B '#3',0
p4          DC.B '#4',0
p5          DC.B '#5',0
p6          DC.B '#6',0
p7          DC.B '#7',0

comma      DC.B ',',0
pound      DC.B '#',0
money      DC.B '$',0
both       DC.B '#$',0

MOVEE      DC.B 'MOVE',0
MOVEA      DC.B 'MOVEA',0

longOp     DC.B '.L ',0
wordOp     DC.B '.W ',0
byteOp     DC.B '.B ',0

working DC.B 'Working!',CR,LF,0
errorM  DC.B 'Address Mode Error',CR,LF,0

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
