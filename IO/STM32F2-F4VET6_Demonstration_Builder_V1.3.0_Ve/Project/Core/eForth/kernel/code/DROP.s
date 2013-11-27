#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_DROP
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_DROP       
;CODE DROP ;( w -- )          ;\ Discard top stack item.
;?  [] TOS, SP, 4 #               ,LDR        \ pop TOS
;    LDR TOS, SP, #4         ;\ pop TOS
;  NEXT
;END-CODE


;CODE DROP ;( w -- )          ;\ Discard top stack item.
    LDR TOS, [SP, #4]         ;               ,LDR        \ pop TOS
    LDR TOS,[SP],#4         ;\ pop TOS
    NEXT
;END-CODE
        END