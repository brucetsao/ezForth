CODE ?branch  ( f -- )                      \ Branch if flag is zero.
 FORWARD:QUESTIONBRANCH1
 FORWARD:QUESTIONBRANCH2
 TOS->WP
 [SP]->TOS,SP+4->SP
 BNE_QUESTIONBRANCH1    ;\ jump if f <> 0  
 [IP]->IP 
 JMP_QUESTIONBRANCH2
 LABEL:QUESTIONBRANCH1
 IP+4->IP
 LABEL:QUESTIONBRANCH2
  $NEXT  \ NEST
END-CODE \ ;CODE


