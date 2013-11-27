#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_Psave
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_Psave       
;CODE P! ( w p -- )          ;\ Pop the data stack to io port.
;  LDR   WP, [SP],# 4        ;\ get w, SP := SP+4
;  STR   WP, [TOS]           ;\ p := w
;  LDR   TOS, [SP], #4       ;\ pop TOS
;  NEXT
;END-CODE 
;CODE P! ( w p -- )          ;\ Pop the data stack to io port.
  LDR   WP, [SP],# 4        ;\ get w, SP := SP+4
  STR   WP, [TOS]           ;\ p := w
  LDR   TOS, [SP], #4       ;\ pop TOS
  NEXT
;END-CODE 
        END