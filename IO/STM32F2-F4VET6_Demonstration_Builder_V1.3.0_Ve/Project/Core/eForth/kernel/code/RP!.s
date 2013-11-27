#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK Forth_RPsave
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_RPsave       
;CODE RP! ( a -- )           ;\ Set the return stack pointer.
;  MOV   RP, TOS             ;\ RP := TOS
;  LDR   TOS, [SP], #4       ;\ pop TOS
;  NEXT
;END-CODE

;CODE RP! ( a -- )           ;\ Set the return stack pointer.
  MOV   RP, TOS             ;\ RP := TOS
  LDR   TOS, [SP], #4       ;\ pop TOS
  NEXT
;END-CODE
        END