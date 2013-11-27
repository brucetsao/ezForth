#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK Forth_R_GT
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_R_GT      
;CODE R> ( -- w )                            \ Pop the return stack to the data stack.
;?  [-P!] TOS, SP, 4 #            ,STR        \ push TOS
;  STR   TOS, [SP], #4       ;\ push TOS
;  LDR   TOS, [RP], #4       ;\ pop TOS from RS
;  NEXT
;END-CODE
;CODE R> ( -- w )                            \ Pop the return stack to the data stack.
  STR   TOS, [SP,#4]         ;            ,STR        \ push TOS
  STR   TOS, [SP], #4       ;\ push TOS
  LDR   TOS, [RP], #4       ;\ pop TOS from RS
  NEXT
;END-CODE
        END