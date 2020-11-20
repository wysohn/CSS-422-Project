*-----------------------------------------------------------
* Title      :I/O
* Written by :Team Awesome
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

STARTING_ADDRESS_PROMPT
    LEA PROMPT_START_ADDRESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA START_ADDRESS,A1
    MOVE.B  #2,D0   * Trap #2 reads input from keyboard
    TRAP    #15
    CMP     #1,D1 ****Check to see if only one digit is in the address

    CMP     #8,D1 ****Comparing if address is 8 digits
    BNE     STARTING_ADDRESS_INVALID_LENGTH
    MOVE.B  #1,D5   *Counter to increment 4 sets (2 digits each) for the address
    MOVE.B  #8,D2 * Counter for letters
    MOVE.B  #0,D4
    MOVE.W  A1,A6   *Copying input start address to A6
    bra PARSE_ADDRESS
PARSE_ADDRESS
    MOVE.B  (A1),D1     
    CMP.B   #$30,D1         *(0-9 is HEX 30-39)
    BGE     CHECK_NUMBER
    
CHECK_NUMBER             
    CMP.B   #$39,D1
    BLE     CONVERT_NUMBER * Convert to hex
    BRA     CHECK_ASCII_LOWERBOUND
    
CHECK_ASCII_LOWERBOUND   *(A-F is HEX 41-46)
    CMP.B   #$41,D1
    BGE     CHECK_ASCII_UPPERBOUND
    
CHECK_ASCII_UPPERBOUND
    CMP.B   #$46,D1
    BLE     CONVERT_LETTER
    
CONVERT_LETTER  
    SUBI.B  #$37,D1
    BRA     CONVERT_NUMBER
    
CONVERT_NUMBER
    SUBI.B  #$30,D1
    
CONVERT
    MOVE.B  D1,(A1)+
    SUBI.B  #1,D2       *Decrements letter counter
    BNE     PARSE_ADDRESS * Loops through the 8 characters of the address
    CMP     #0,D2   ******************
    JSR     CHECK_ODD  *Jumps to sub routine to check if odd
    MOVE.L  A6,A1   *Moving
    MOVE.B  #4,D2
    MOVE.B  #1,D5
    BRA     MULTIPLY_BY_$10
    
MULTIPLY_BY_$10         *Converts ny mulitplying $10 which is decimal 16
    CMP.B   #0,D2
    BEQ     STORE_ADDRESSES
    CMP.B   #2,D5
    BEQ     ADD
    MOVE.B  (A6),D1
    MULU    #$10,D1
    MOVE.B  D1,(A1)
    MOVE.L  A6,D7
    ADDI.B  #1,D7
    MOVE.L  D7,A6
    ADDI.B  #1,D5
    
ADD
    MOVE.B  (A6),D6     
    ADD.B   D6,(A1)
    MOVE.B  #1,D5
    MOVE.L  A6,D7
    ADDI.B  #1,D7
    MOVE.L  D7,A6
    
    MOVE.L  A1,D7
    ADDI.B  #1,D7
    MOVE.L  D7,A1
    SUBI.B  #1,D2
    BRA     MULTIPLY_BY_$10
    
STORE_ADDRESSES
    MOVE.L  A6,D1
    SUBI.B  #8,D1
    MOVEA.L D1,A6
    MOVE.L  (A6),D1
    CMP.B   #1,D4   * Counter
    BEQ     STORE_ENDING_ADDRESS
    MOVE.L  D1,A3   * Input stored in A3
    ADD.B   #1,D4
    BRA     END_ADDRESS_PROMPT
    
STORE_ENDING_ADDRESS
    MOVE.L  D1,A0   * Store ending address into A0
    BRA     COMPARE_START_AND_END
    
CHECK_ODD
    MOVE.B  -(A1),D2    *Moving last digit of address to be checked
    CMP.B   #1,D2
    BEQ     ODD
    CMP.B   #3,D2
    BEQ     ODD
    CMP.B   #5,D2
    BEQ     ODD
    CMP.B   #7,D2
    BEQ     ODD
    CMP.B   #9,D2
    BEQ     ODD
    CMP.B   #$B,D2
    BEQ     ODD
    CMP.B   #$D,D2
    BEQ     ODD
    CMP.B   #$F,D2
    BEQ     ODD
    RTS             *Returns back to CONVERT subroutine to continue reading the address
    
    
STARTING_ADDRESS_INVALID_LENGTH
    LEA START_ADDRESS_INV_MESSAGE,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     STARTING_ADDRESS_PROMPT

ENDING_ADDRESS_INVALID_LENGTH
    LEA END_ADDRESS_INV_MESSAGE,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     END_ADDRESS_PROMPT

ODD
    LEA MESSAGE_ODD,A1
    MOVE.B  #14,D0
    TRAP    #15
    CMP.B   #1,D4
    BRA     STARTING_ADDRESS_PROMPT     *loops back to beginning if address is invalid
    
END_ADDRESS_PROMPT
    LEA PROMPT_END_ADDRESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA END_ADDRESS,A1
    MOVEA.L A6,A1
    MOVE.B  #2,D0 
    TRAP    #15
    CMP     #8,D1                       * Check if input is 8 char long
    BNE     ENDING_ADDRESS_INVALID_LENGTH  *loops back to ask for ending address
    
    MOVE.B  #8,D2
    BRA     PARSE_ADDRESS
    
COMPARE_START_AND_END
    MOVE.L  A3,A4           *Copying end address to A4 to check for error if it is smaller than start address
    SUB.L   A0,A4           *Subtracting end address from start address
    CMP     #0,A4
    BGT     START_GREATER_THAN_END
    BRA     CLEAR
    
START_GREATER_THAN_END
    LEA MESSAGE_START_GREATER_THAN_END,A1
    MOVE.B  #14,D0
    TRAP    #15
    CLR.B   D4
    BRA     STARTING_ADDRESS_PROMPT     *goes back to beginining 
      
CLEAR
    SUBA.L	A1,A1
    SUBA.L	A4,A4
    SUBA.L	A5,A5
    SUBA.L	A6,A6     
    CLR.L		D0
    CLR.L		D1
    CLR.L		D4
    CLR.L		D5
    CLR.L		D7
    
    MOVE.B  #$00,(A6)

    SIMHALT             ; halt simulator

* Put variables and constants here
CR  EQU $0D
LF  EQU $0A
PROMPT_START_ADDRESS DC.B   'Please enter a starting hex address ( 8 characters XXXXXXXX)',CR,LF,0
PROMPT_END_ADDRESS DC.B   'Please enter an ending hex address ( 8 characters XXXXXXXX)',CR,LF,0
START_ADDRESS   DS.L    1
END_ADDRESS     DS.L    1
START_ADDRESS_INV_MESSAGE   DC.B    'START ADDRESS IS INVALID LENGTH',CR,LF,0
END_ADDRESS_INV_MESSAGE    DC.B    'END ADDRESS IS INVALID LENGTH',CR,LF,0
MESSAGE_START_GREATER_THAN_END  DC.B    'Start address cannot be greater than end addresss',CR,LF,0
MESSAGE_ODD            DC.B    'Invalid, address cannot be odd',CR,LF,0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
