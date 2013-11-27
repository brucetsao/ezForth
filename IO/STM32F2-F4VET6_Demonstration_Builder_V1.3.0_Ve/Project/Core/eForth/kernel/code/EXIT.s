#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_EXIT
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_EXIT      
;CODE EXIT    ( -- )         ;\ Terminate a colon definition.
;  LDR   IP, [RP], #4        ;\ pop IP
;  NEXT
;END-CODE


;CODE EXIT    ( -- )         ;\ Terminate a colon definition.
  LDR   IP, [RP], #4        ;\ pop IP
  NEXT
;END-CODE
        END