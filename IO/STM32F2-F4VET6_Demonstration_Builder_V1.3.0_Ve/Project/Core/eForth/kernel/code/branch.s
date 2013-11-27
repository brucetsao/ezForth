#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_Branch
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_Branch       
;CODE branch  ( -- )         ;\ Branch to an inline address.
;  LDR   IP,[IP]             ;\ IP := [IP]
;  NEXT
;END-CODE

;CODE branch  ( -- )         ;\ Branch to an inline address.
  LDR   IP,[IP]             ;\ IP := [IP]
  NEXT
;END-CODE
        END