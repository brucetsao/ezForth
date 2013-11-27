#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK Forth_SPsave
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_SPsave       
;CODE SP! ;( a -- )          ;\ Set the data stack pointer.
;  MOV   SP, TOS             ;\ SP := TOS
;  LDR   TOS,[SP],#4         ;\ pop TOS
;  NEXT
;END-CODE
;CODE SP! ;( a -- )          ;\ Set the data stack pointer.
  MOV   SP, TOS             ;\ SP := TOS
  LDR   TOS,[SP],#4         ;\ pop TOS
  NEXT
;END-CODE
        END