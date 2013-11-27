#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_Csave
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_Csave      
;CODE C! ( c b -- )          ;\ Pop the data stack to byte memory.
;  LDR   WP, [SP], #4        ;\ get c, SP := SP+4
;  STRB  WP,[TOS]            ;\ b := c
;  LDR   TOS,[SP],#4         ;\ pop TOS
;  NEXT
;END-CODE

;CODE C! ( c b -- )          ;\ Pop the data stack to byte memory.
  LDR   WP, [SP], #4        ;\ get c, SP := SP+4
  STRB  WP,[TOS]            ;\ b := c
  LDR   TOS,[SP],#4         ;\ pop TOS
  NEXT
;END-CODE
          END