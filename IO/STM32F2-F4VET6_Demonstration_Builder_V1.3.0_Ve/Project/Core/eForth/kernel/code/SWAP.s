#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK Forth_SWAP
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_SWAP       
;CODE SWAP ;( w1 w2 -- w2 w1 )   ;\ Exchange top two stack items.
;  LDR   WP, [SP]            ;\ WP := [SP]
;  STR   TOS, [SP]           ;\ [SP] := TOS
;  MOV   TOS, WP             ;\ TOS := WP
;  NEXT
;END-CODE
;CODE SWAP ;( w1 w2 -- w2 w1 )   ;\ Exchange top two stack items.
  LDR   WP, [SP]            ;\ WP := [SP]
  STR   TOS, [SP]           ;\ [SP] := TOS
  MOV   TOS, WP             ;\ TOS := WP
  NEXT
;END-CODE
        END