#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_RPat
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_RPat       
;CODE RP@ ( -- a )           ;\ Push the current RP to the data stack.
;?  [-P!] TOS, SP, 4 #            ,STR        \ push TOS
;  STR   TOS, [SP], #4       ;\ push TOS  
;  MOV   TOS, RP             ;\ TOS := RP
;  NEXT
;END-CODE

;CODE RP@ ( -- a )           ;\ Push the current RP to the data stack.
  str   TOS, [SP, #4]        ;            ,STR        \ push TOS
  STR   TOS, [SP], #4       ;\ push TOS  
  MOV   TOS, RP             ;\ TOS := RP
  NEXT
;END-CODE
        END