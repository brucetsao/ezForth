#include "Arm_eForth.h"

;CODE ! ( w a -- )           ;\ Pop the data stack to memory.
;  LDR   WP, [SP], #4        ;\ get w, SP := SP+4
;  STR   WP, [TOS]           ;\ a := w
;  LDR   TOS,[SP],#4         ;\ pop TOS
;  NEXT
;END-CODE 

;MODULE  Forth
        PUBWEAK Forth_Exclamation
        SECTION .ForthRom:CODE:NOROOT(2)
        THUMB
        
       Forth_CODE 
Forth_Exclamation        
       LDR WP,[SP],#4 
       STR WP,[TOS]              
       LDR TOS,[SP],#4
       NEXT
       Forth_EndCODE
       END
       
       