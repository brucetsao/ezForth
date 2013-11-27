#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_LIT
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_LIT       
;CODE doLIT  ( -- w )                        \ Push an inline literal.
;  STR   TOS, [SP], #4       ;\ push TOS
;  LDR   TOS, [IP], #4       ;\ TOS := [IP], IP := IP+4
;  NEXT
;END-CODE

;CODE doLIT  ( -- w )                        \ Push an inline literal.
  STR   TOS, [SP], #4       ;\ push TOS
  LDR   TOS, [IP], #4       ;\ TOS := [IP], IP := IP+4
  NEXT
;END-CODE
        END