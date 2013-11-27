#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK zero_LT
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
zero_LT        
; CODE 0< ;( n -- t )         ;\ Return true if n is negative.
;  MOV   WP, #0              ;\ WP := 0
;  ADD   TOS, WP, TOS,ASR#20 ;\ TOS := 0 + (0|-1)
;  NEXT
;END-CODE

    ;CODE 0< ;( n -- t )         ;\ Return true if n is negative.
    MOV   WP, #0              ;\ WP := 0
    ADD   TOS, WP, TOS,ASR#20 ;\ TOS := 0 + (0|-1)
    NEXT
   ;END-CODE
 
 END