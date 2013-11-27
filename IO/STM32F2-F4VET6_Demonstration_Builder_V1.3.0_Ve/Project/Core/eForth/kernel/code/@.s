#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_AT
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_AT
;CODE @ ( a -- w )           ;\ Push memory location to the data stack.
;  LDR   TOS,[TOS]           ;\ TOS := [TOS]
;  NEXT
;END-CODE

;CODE @ ( a -- w )           ;\ Push memory location to the data stack.
  LDR   TOS,[TOS]           ;\ TOS := [TOS]
  NEXT
;END-CODE
        END