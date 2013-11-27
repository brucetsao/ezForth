#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK Forth_Rat
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_Rat       
;CODE R@ ;( -- w )           ;\ Copy top of return stack to the data stack.
;  STR   TOS,[SP],#4         ;\ push TOS
;  LDR   TOS,[RP]            ;\ TOS := [RP]
;  NEXT
;END-CODE 
;CODE R@ ;( -- w )           ;\ Copy top of return stack to the data stack.
  STR   TOS,[SP],#4         ;\ push TOS
  LDR   TOS,[RP]            ;\ TOS := [RP]
  NEXT
;END-CODE 
        END