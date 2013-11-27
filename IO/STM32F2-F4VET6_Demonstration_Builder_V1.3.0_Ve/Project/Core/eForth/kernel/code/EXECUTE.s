#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_EXECUTE
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_EXECUTE       
;CODE EXECUTE ( ca -- )      ;\ Execute the word at ca.
;  MOV   WP, TOS,            ;\ get next CFA
;  LDR   TOS, [SP], #4       ;\ pop TOS
;  BX    WP                  ;\ jump to next CFA
  
;CODE EXECUTE ( ca -- )      ;\ Execute the word at ca.
  MOV   WP, TOS            ;\ get next CFA
  LDR   TOS, [SP], #4       ;\ pop TOS
  BX    WP                  ;\ jump to next CFA  
        END