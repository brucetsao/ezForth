CODE UM* ( u1 u2 -- udl udh )               \ Unsigned multiply. Return double product.
  [] WP, SP                     ,LDR        \ WP := u1
  XP, TOS, TOS, WP              ,UMULL      \ TOS:XP := TOS*WP
  [] XP, SP                     ,STR        \ [SP] := XP(udl)
  $NEXT
END-CODE

\ : CMOVE ( b1 b2 u -- )                      \ Copy u bytes from b1 to b2.
\  FOR AFT >R COUNT R@ C! R> 1 + THEN NEXT 2DROP ;
CODE CMOVE ( b1 b2 u -- )                   \ Copy u bytes from b1 to b2.
  [] XP, SP, 4 #                ,LDR        \ XP := [SP](b2)  , SP := SP+4            
  [] YP, SP, 4 #                ,LDR        \ YP := [SP](b1)  , SP := SP+4
  PC, PC, 4 #                   ,ADD        \ skip first time  
  [B] WP, YP, 1 #               ,LDR        \ WP := byte[YP]  , YP := YP+1
  [B] WP, XP, 1 #               ,STR        \ [XP] := byte WP , XP := XP+1
  S, TOS, TOS                   ,MOV        \ TOS := TOS
  EQ, PC, PC, 4 #               ,ADD        \ PC := PC+4
  TOS, TOS, 1 #                 ,SUB        \ TOS := TOS-1
  PC, PC, 1C #                  ,SUB        \ go back loop
  [] TOS, SP, 4 #               ,LDR        \ TOS := [SP]     , SP := SP+4
  $NEXT
END-CODE 