#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_Cat
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_Cat       
;CODE C@ ( b -- c )          ;\ Push byte memory location to the data stack.
;  LDRB  TOS, [TOS]          ;\ TOS := byte [TOS]
;  NEXT
;END-CODE
;CODE C@ ( b -- c )          ;\ Push byte memory location to the data stack.
  LDRB  TOS, [TOS]          ;\ TOS := byte [TOS]
  NEXT
;END-CODE
        END