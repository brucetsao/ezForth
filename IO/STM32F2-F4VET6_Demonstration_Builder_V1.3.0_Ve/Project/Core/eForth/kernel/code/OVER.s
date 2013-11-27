#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_OVER
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_OVER       
;CODE OVER ;( w1 w2 -- w1 w2 w1 )             ;\ Copy second stack item to top.
;?  [-P!] TOS, SP, 4 #            ,STR        \ push TOS
;?  [P] TOS, SP, 4 #              ,LDR        \ TOS := [SP+4] ;

; STR   TOS,[SP],#4         ;\ push TOS
;  LDR   TOS,[SP],#4         ;\ TOS := [SP+4]
;  NEXT
;END-CODE  
;CODE OVER ;( w1 w2 -- w1 w2 w1 )             ;\ Copy second stack item to top.

    STR   TOS,[SP, #4]           ;       ,STR        \ push TOS
    LDR   TOS,[SP, #4]           ;         ,LDR        \ TOS := [SP+4] 
    STR   TOS,[SP],#4         ;\ push TOS
    LDR   TOS,[SP],#4         ;\ TOS := [SP+4]
  NEXT
;END-CODE  
        END