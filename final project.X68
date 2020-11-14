*-----------------------------------------------------------
* Title      : Dis-assembler
* Written by : Team Awesome
* Date       :
* Description:
*-----------------------------------------------------------

START    ORG    $1000      ; first instruction of program

* start of program

* start of IO
IO:
    NOP
* end of IO

* start of OpCodes
OPCODES:
    NOP
* end of OpCodes

* start of EA
EFFECTIVEADDRESS:
    NOP
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
