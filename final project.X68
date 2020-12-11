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
    EffectiveAddress:                  ; Starts EA section by comparing the opcodeRef Passed to figure out opcode EA to decode

        
         MOVE.L (A0),D3
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

sec3Loop4 LSL.L #1,D3    ;gets ea mode and stores it in D6
         BCS   sec3Loop5
         LSL.L  #1,D6
     
         ADDQ.B #1,D2
         CMP.B  #4,D2
         BEQ   resetsetsetD2
         BRA   sec3Loop4
         
 
sec3Loop5 LSL.L  #1,D6
         ADD.B #%1,D6
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
         BEQ   nextSec3
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
LeaTest2 ;Currently working on---------------------------
LeaPrint

NotEA

JsrEA    

RtsEA   BRA end

AddqEA

BgtEA

BleEA    

BeqEA

BraEA

MoveqEA

;---------------------------------Section 3: OR,SUB,ADD,ADDA,AND-------------------------------------------------------

OrEA     
         
SubEA   
         
AndEA    LEA     Working,A1 
      MOVE.B  #14,D0
      TRAP    #15

AddEA LEA     Working,A1 
      MOVE.B  #14,D0
      TRAP    #15
      
      CMP.B #%00000000,D5 ;Byte
      BEQ   DnDest
      CMP.B #%00000001,D5 ;Word
      BEQ   DnDest
      CMP.B #%00000010,D5 ;Long These three are if Dn is the destination
      BEQ   DnDest
      CMP.B #%00000100,D5 ;Byte
      BEQ   DnSrc
      CMP.B #%00000101,D5 ;Word
      BEQ   DnSrc
      CMP.B #%00000110,D5 ;Long These three are if Dn is the src
      BEQ   DnSrc
      
DnDest  

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
      
SrcSec

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
errorM  DC.B 'Address Mode Error',CR,LF,0
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

END:
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
