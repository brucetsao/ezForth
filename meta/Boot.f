MEM_BASE ORG 
ASSEMBLER
SP, 80000000 #  ,MOV                         \ SP :=80000000
SP, SP, 0200 #  ,ADD                         \ SP :=80000200
WP, FF #        ,MOV                         \ WP :=FF
[] WP, SP       ,STR                         \ [SP] := WP

SP, 0 #         ,MOV                         \ SP :=0
RP, $60000000 # ,MOV                         \ RP :=$60000000
LABEL: SYSTEM_MOVE
[] WP,  SP, 4 # ,LDR                         \ WP := [SP], SP:=SP+4  
[] WP,  RP, 4 # ,STR                         \ [RP] := WP, RP:=RP+4
SP, $8000 #     ,CMP                         \ Finish?
NE, SYSTEM_MOVE # ,B                         \ do again      

[P] SP, PC, 4 # ,LDR                         \ SP := [PC] (=SPP)
[P] RP, PC, 4 # ,LDR                         \ RP := [PC] (=RPP)
[P] PC, PC, 4 # ,LDR                         \ Jump to COLD
=SPP ,
=RPP ,
' COLD ,