( Including Assembler )
IN-ASSEMBLER
FLOAD asm/Arm7/ARM7ASM.F

( Registers of ARM7 eForth VM ) 
: IP R0 ;
: SP R1 ;
: RP R2 ;
: UP R3 ;
: WP R4 ;
: TOS R5 ;
: XP R6 ;
: YP R7 ;
: LP R14 ;
: PC R15 ;

: IP, R0, ;
: SP, R1, ;
: RP, R2, ;
: UP, R3, ;
: WP, R4, ;
: TOS, R5, ;
: XP, R6, ;
: YP, R7, ;
: LP, R14, ;
: PC, R15, ;

IN-META
: HERE-I HERE-T THERE ;

( Patch assembler )
' IMAGE   ASSEMBLER    IS IMAGE    META
' HERE-I  ASSEMBLER    IS HERE-I   META 
' ,-T     ASSEMBLER    IS ,        META