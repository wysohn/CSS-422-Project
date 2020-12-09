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

* start of IO
IO:
    ; do some IO works...

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
    CLR.L   D0
    CLR.L	D1
    CLR.L	D4
    CLR.L	D5
    CLR.L	D7
    
    MOVE.B  #$00,(A6)
    LEA     VALUES,A2   *loading all the ascii characters  
  
*******************STARTING the disassembly**********************************************************************************************************    
DISASSEMBLE     
    *CMP.L   A0,A3           *Checks start and end addresses to move into main part of program 
    *BGT     START
    MOVE.L  PRINTBUFFER,A1
    LEA     ADDRESS_INCREMENTER,A6
    JSR     IS_NOP_OR_RTS   *Checking if NOP or RTS first 
    
IS_NOP_OR_RTS               *Check for NOP or RTS because they differ from the rest 
     MOVE.W (A3),D6
     CMP.W  #$4E71,D6       *$4E71 is NOP
     BEQ    NOP
     CMP.W  #$4E75,D6       *$4E75 is RTS  
     BEQ    IS_RTS
     RTS
NOP                         * Subroutine if we decode NOP
    JSR PRINT_ADDRESS
    JSR PRINT_NOP
    JSR PRINT_HEX_WORD
    
IS_RTS
    JSR PRINT_ADDRESS
    JSR PRINT_RTS
    JSR PRINT_HEX_WORD
    
PRINT_ADDRESS               *****PRINTS the memory address the instruction is at********
    LEA PRINTBUFFER,A1
    MOVE.L  A3,D6
    JSR PRINT_0                     *68K always has address of 00XXXXXX, so we print 2 zeros
    JSR PRINT_0                     
    LSR.L   #8,D6                   *Shift bits to isolate 3rd digit in address  
    LSR.L   #8,D6
    LSR.L   #4,D6
    MOVE.B  (A2,D6),(A1)+           *Move digit ascii to PRINTBUFFER 
    MOVE.L  A3,D6                   *Re-set the address because it was modified
    LSL.L   #8,D6                   *Shift bits to isolate 4th digit in address
    LSL.L   #4,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #4,D6
    MOVE.B  (A2,D6),(A1)+          
    MOVE.L  A3,D6                  
    LSL.L   #8,D6                  
    LSL.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #4,D6
    MOVE.B  (A2,D6),(A1)+          
    MOVE.L  A3,D6                   
    LSL.L   #8,D6                   
    LSL.L   #8,D6
    LSL.L   #4,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #4,D6
    MOVE.B  (A2,D6),(A1)+           
    MOVE.L  A3,D6                   
    LSL.L   #8,D6                   
    LSL.L   #8,D6
    LSL.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #4,D6
    MOVE.B  (A2,D6),(A1)+          
    MOVE.L  A3,D6                  
    LSL.L   #8,D6                  
    LSL.L   #8,D6
    LSL.L   #8,D6
    LSL.L   #4,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #8,D6
    LSR.L   #4,D6
    MOVE.B  (A2,D6),(A1)+           *Move all the ascii to PRINTERbuffer
    JSR     PRINT_TAB               *Add a tab for the spacing 
    CLR.L   D6
    RTS
    
PRINT_HEX_WORD
    MOVE.W  (A3),D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    MOVE.B  (A2,D6),(A1)+
    MOVE.W  (A3),D6
    LSL.W   #4,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    MOVE.B  (A2,D6),(A1)+
    MOVE.W  (A3),D6
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    MOVE.B  (A2,D6),(A1)+
    MOVE.W  (A3),D6
    LSL.W   #8,D6
    LSL.W   #4,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    MOVE.B  (A2,D6),(A1)+
    CLR.W   D6
    RTS

PRINT_TAB                        * Adds a tab to the print buffer
    MOVE.B   #$09,(A1)+           
    RTS

PRINT_DATA                      *Prints the ASCII string 'DATA'
    MOVE.B   13(A2),(A1)+
    MOVE.B   10(A2),(A1)+
    MOVE.B   29(A2),(A1)+ 
    MOVE.B   10(A2),(A1)+
    JSR     PRINT_TAB
    RTS
                 
PRINT_0                         *Prints ASCII 0(zero)
    MOVE.B  0(A2),(A1)+
    
    
PRINT_NOP
    MOVE.B  23(A2),(A1)+        *N
    MOVE.B  24(A2),(A1)+        *O
    MOVE.B  25(A2),(A1)+        *P
    RTS    
    
PRINT_RTS
    MOVE.B   27(A2),(A1)+        *R
    MOVE.B   29(A2),(A1)+        *T
    MOVE.B   28(A2),(A1)+        *S
    RTS
    

***********************MAIN PRINT SUBROUTINE*************************
PRINT
    MOVE.B   #$00,(A1)           *Need the 00 as the terminator of the string;
    MOVE.L PRINTBUFFER,A1        
    MOVE.B   #13,D0            
    TRAP #15
    BRA NEXT_INSTRUCTION  
NEXT_INSTRUCTION
    MOVEA.L  #0,A4
   * MOVE.B  #2,(A6)             *Re-set the counter for address incrementer
    CLR.L   D0
    CLR.L   D1
    CLR.L   D2
    CLR.L   D3
    CLR.L   D4
    CLR.L   D5
    CLR.L   D6
    ADDI.B  #2,(A6)         
    BRA IF_DONE
IF_DONE
    CMP.L   A3,A0
    BLT     DONE
    BRA     DISASSEMBLE
DONE

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
    EffectiveAddress:                  ; Starts EA section by comparing the opcodeRef Passed to figure out opcode EA to decode
         MOVE.L #8,opcodeRef   ;for Testing opcodeRef entries
         MOVE.L #1,D2          ;Counter for comparisons
    
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
    
         CMP.L  opcodeRef,D2           ;First compare the opcode value to branch to proper EA decoding section
         BEQ    OrEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    SubEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    AndEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    AddEA
         ADDQ.B #1,D2
    
         CMP.L  opcodeRef,D2           
         BEQ    AddaEA
         ADDQ.B #1,D2
         
MoveMovea  

MoveEA

MoveaEA

NopEA

MovemEA

LeaEA

NotEA

JsrEA    

RtsEA

AddqEA

BgtEA

BleEA    

BeqEA

BraEA

MoveqEA

OrEA     
         
SubEA   
         
AndEA    

AddEA   

AddaEA       
         
EndEA   
        
LslEA

LrsEA

AslEA

AsrEA

RolEA

RorEA


    RTS
* end of EA

* end of program

    SIMHALT             ; halt simulator

* Put variables and constants here

END:
    END    START        ; last line of source
* Put variables and constants here
VALUES   DC.B  '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','.',',','$','(',')','#','+','-' 
               *0   1    2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40  41  42  43
CR  EQU $0D
LF  EQU $0A
PROMPT_START_ADDRESS DC.B   'Please enter a starting hex address ( 8 characters XXXXXXXX)',CR,LF,0
PROMPT_END_ADDRESS DC.B   'Please enter an ending hex address ( 8 characters XXXXXXXX)',CR,LF,0
DATA DC.B   'DATA',CR,LF,0
START_ADDRESS   DS.L    1
END_ADDRESS     DS.L    1
START_ADDRESS_INV_MESSAGE   DC.B    'START ADDRESS IS INVALID LENGTH',CR,LF,0
END_ADDRESS_INV_MESSAGE    DC.B    'END ADDRESS IS INVALID LENGTH',CR,LF,0
MESSAGE_START_GREATER_THAN_END  DC.B    'Start address cannot be greater than end addresss',CR,LF,0
MESSAGE_ODD            DC.B    'Invalid, address cannot be odd',CR,LF,0
ADDRESS_INCREMENTER DC.B   0
PRINTBUFFER         DC.L    0

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

