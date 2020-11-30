*-----------------------------------------------------------
* Title      : Dis-assembler
* Written by : Team Awesome
* Date       :
* Description:
*-----------------------------------------------------------

START    ORG    $1000      ; first instruction of program

; Opcodes follow specific patterns
* MOVE, MOVEA
* 0 0 ? ?
OPMOVE EQU %00
* NOP, MOVEM, LEA, NOT, JSR, RTS
* 0 1 0 0 
OPSPCIAL    EQU %0100
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
    ; do some IO works...
    JSR OPCODES
* end of IO

* start of OpCodes
OPCODES:
    ; decode opcode parts
    JSR EFFECTIVEADDRESS
    
    RTS
* end of OpCodes

* start of EA
EFFECTIVEADDRESS:
    ; do some EA works...
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
