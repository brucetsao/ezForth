#include "Arm_eForth.h"
;MODULE  Forth
        PUBWEAK Forth_doLIST
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_doLIST       
;CODE doLIST  ( -- )         ;\ Colon word run-time code   
;?  [-P!] IP, RP, 4 #             ,STR        \ push IP
;    STR IP, [RP], #4        ;\ push IP
;  MOV   IP, LP              ;\ IP := LP
;  NEXT
;END-CODE 

;CODE doLIST  ( -- )         ;\ Colon word run-time code   
    STR IP, [RP, #4 ] ;          ,STR        \ push IP
    STR IP, [RP], #4        ;\ push IP
  MOV   IP, LP              ;\ IP := LP
  NEXT
;END-CODE 
        END