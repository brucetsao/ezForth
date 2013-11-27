#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK Forth_SPat
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_SPat       
;CODE SP@ ;( -- a )          ;\ Push the current data stack pointer.
;?  [-P!] TOS, SP, 4 #            ,STR        \ push TOS
;  STR   TOS, [SP], #4       ;\ push TOS
;  MOV   TOS, SP             ;\ TOS := SP
;  NEXT
;END-CODE 

;CODE SP@ ;( -- a )               ;\ Push the current data stack pointer.
        STR   TOS, [SP, #4]       ;            ,STR        \ push TOS
        STR   TOS, [SP], #4       ;\ push TOS
        MOV   TOS, SP             ;\ TOS := SP
        NEXT
;END-CODE 
        END