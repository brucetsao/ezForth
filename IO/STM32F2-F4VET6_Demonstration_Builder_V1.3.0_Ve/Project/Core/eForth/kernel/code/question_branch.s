#include "Arm_eForth.h"

;MODULE  Forth
        PUBWEAK Forth_question_branch
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_question_branch       

;CODE ?branch  ( f -- )                      \ Branch if flag is zero.
;FORWARD: QUESTIONBRANCH1
;FORWARD: QUESTIONBRANCH2
;  MOVS  WP, TOS             ;\ get f
;  LDR   TOS, [SP], #4       ;\ pop TOS
;  BNE   #QUESTIONBRANCH1    ;\ jump if f <> 0  
;  LDR   IP, [IP]            ;\ IP := [IP]
;  B     #QUESTIONBRANCH2    ;\ exit
;LABEL: QUESTIONBRANCH1
;  ADD   IP, IP, #4          ;\ IP := IP+4
;LABEL: QUESTIONBRANCH2
;  NEXT
;  END-CODE
  
  
;CODE ?branch  ( f -- )                      \ Branch if flag is zero.
;FORWARD: QUESTIONBRANCH1
;FORWARD: QUESTIONBRANCH2
  MOVS  WP, TOS             ;\ get f
  LDR   TOS, [SP], #4       ;\ pop TOS
;  BNE   #QUESTIONBRANCH1    ;\ jump if f <> 0  
  LDR   IP, [IP]            ;\ IP := [IP]
;  B     #QUESTIONBRANCH2    ;\ exit
;LABEL: QUESTIONBRANCH1
  ADD   IP, IP, #4          ;\ IP := IP+4
;LABEL: QUESTIONBRANCH2
  NEXT
;  END-CODE
  
        END