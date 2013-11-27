#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_GT_R
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_GT_R       
;CODE >R ;( w -- )           ;\ Push the data stack to the return stack.
;?  [-P!] TOS, RP, 4 #            ,STR        \ push TOS to RS
;    STR TOS,[RP],#4         ;\ push TOS to RS
;    LDR TOS,[SP],#4         ;\ pop TOS
;  NEXT  
;END-CODE
;CODE >R ;( w -- )           ;\ Push the data stack to the return stack.
        STR TOS, [RP, #4]    ; #            ,STR        \ push TOS to RS
        STR TOS,[RP],#4         ;\ push TOS to RS
        LDR TOS,[SP],#4         ;\ pop TOS
        NEXT  
;END-CODE
        END