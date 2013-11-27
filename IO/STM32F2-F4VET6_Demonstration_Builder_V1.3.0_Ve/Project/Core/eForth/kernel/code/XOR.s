#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK Forth_XOR
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_XOR       
;CODE XOR ;( w w -- w )      ;\ Bitwise exclusive OR.
;  LDR   WP,[SP],#4          ;\ WP = [SP], SP := SP+4
;  eor   TOS,TOS,WP          ;\ TOS := TOS xor WP
;  NEXT
;END-CODE 
;CODE XOR ;( w w -- w )      ;\ Bitwise exclusive OR.
  LDR   WP,[SP],#4          ;\ WP = [SP], SP := SP+4
  eor   TOS,TOS,WP          ;\ TOS := TOS xor WP
  NEXT
;END-CODE 
        END