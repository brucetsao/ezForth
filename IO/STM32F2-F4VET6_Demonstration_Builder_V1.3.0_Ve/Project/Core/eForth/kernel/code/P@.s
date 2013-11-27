#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK Forth_Pat
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_Pat       
;CODE P@ ( p -- w )          ;\ Push io port to the data stack.
;  LDR TOS,[TOS]             ;\ TOS := [TOS]
;  NEXT
;END-CODE

;CODE P@ ( p -- w )          ;\ Push io port to the data stack.
  LDR TOS,[TOS]             ;\ TOS := [TOS]
  NEXT
;END-CODE
        END