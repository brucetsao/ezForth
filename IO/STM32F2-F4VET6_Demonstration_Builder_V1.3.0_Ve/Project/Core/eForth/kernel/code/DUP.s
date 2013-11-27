#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_DUP
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_DUP       
;CODE DUP ;( w -- w w )                       ;\ Duplicate the top stack item.
;?  [-P!] TOS, SP, 4 #            ,STR        \ push TOS
;  STR   TOS, [SP], #4 
;  NEXT
;END-CODE  
;CODE DUP ;( w -- w w )                       ;\ Duplicate the top stack item.
     STR        TOS, [SP, #4]                 ;             ,STR        \ push TOS
     STR        TOS, [SP], #4 
     NEXT
;END-CODE  
        END