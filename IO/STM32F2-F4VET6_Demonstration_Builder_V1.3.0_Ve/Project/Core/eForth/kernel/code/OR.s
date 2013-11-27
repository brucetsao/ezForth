#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_OR
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_OR       
;CODE OR ;( w w -- w )        ;\ Bitwise inclusive OR.
;  LDR   WP, [SP],#4         ;\ WP = [SP], SP := SP+4
;  ORR   TOS, TOS, WP        ;\ TOS := TOS or WP
;  NEXT
;END-CODE
;CODE OR ;( w w -- w )        ;\ Bitwise inclusive OR.
  LDR   WP, [SP],#4         ;\ WP = [SP], SP := SP+4
  ORR   TOS, TOS, WP        ;\ TOS := TOS or WP
  NEXT
;END-CODE  
        END