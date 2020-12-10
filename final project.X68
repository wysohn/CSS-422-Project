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
        ; MOVE.L #21,opcodeRef   ;for Testing opcodeRef entries
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
decSec4  MOVE.W #16,numberBits
         LSL.L #4,D3   ;gets rid of first 4 bits
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
            
sec4EA     MOVE.B #32,D2  ;Merge these two sections of moving data, then just move word for word and move long for long
           MOVE.L #$00000000,D1
           MOVEA A0,A3
           ADDA #16,A3
           MOVE.L (A3),D3
 
sec4WordLoop LSL.L #1,D3    
             BCS   sec4WordLoop1
             LSL.L  #1,D1
     
             ADDQ.B #1,D2
             CMP.B  #33,D2
             BEQ   sec4addval
             BRA   sec4WordLoop 
sec4WordLoop1 LSL.L  #1,D1
              ADD.B #%1,D1
              ADDQ.B #1,D2
              CMP.B  #33,D2
              BEQ   sec4addval
              BRA   sec4WordLoop


sec4addval   CMP.B #%000,D7
            BEQ   sec4Word
            CMP.B #%001,D7
            BEQ   sec4Long
            BRA   printError
sec4Word    MOVE.W (A3),D2  ;ask about******************
            BRA    sec4Print

sec4Long    MOVE.L  (A3),D2 

sec4Print   LEA     money,A1 
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.L  D2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            BRA     end
            
;Just needs to be tested with other code----------------------------------------------------------------------------------------------------
            
   
MoveMovea  

MoveEA

MoveaEA

NopEA    BRA end

MovemEA

LeaEA

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
         


printError LEA     errorM,A1 
           MOVE.B  #14,D0
           TRAP    #15

end   LEA     EndBRA,A1 
      MOVE.B  #14,D0
      TRAP    #15
      ;RTS


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

working DC.B 'Working!',CR,LF,0
errorM  DC.B 'Address Mode Error',CR,LF,0



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
