HEX
' AND    alias forthAND
' ,      alias forth,

DEFER IMAGE                       \ Assembly Code Space
DEFER HERE-I                      \ current assembly counter
DEFER ,                           \ Assembly a word to current assembly counter

: $ HERE-I ;                      \ current assembly counte      

 

\ Forward reference define words
VARIABLE FORWARD-LINK  0 FORWARD-LINK !            \ default link to nothing

: FORWARD:  ( -- )
  CREATE HERE                                      \ get pfa
  FORWARD-LINK @ forth,                            \ fill outer-link
  FORWARD-LINK !                                   \ reset outer-link 
  FALSE forth,                                     \ resolve flag
  0 forth,                                         \ count
  0 forth,                                         \ default inner-link
  DOES> ( -- n )
    DUP $04 + @                                    \ get resolve flag
      IF $0C + @                                   \ get location of resolved
      ELSE DUP $08 + 1 SWAP +!                     \ increase counter 
           $0C + DUP @                             \ get last inner-link
           SWAP HERE-I SWAP !                      \ reset inner-link
      THEN
  ;
 
: RESOLVE  ( addr pfa -- )
  DUP $04 + TRUE SWAP !    ( addr pfa )           \ set flag as resolved
  DUP $0C + @              ( addr pfa link )      \ get current inner-link
  SWAP $08 + @ 0 ?DO       ( addr link )          \ setup resolve loop
    SWAP >R                ( link )               \ save resolved address to R 
    DUP @ $FFFFFF forthAND 2 LSHIFT 8 +  ( link offset )  \ get the next inner-link to resolve from image
    DUP 02000000 forthAND  ( link offset offset ) \ extend sign
      IF FC000000 +  THEN  ( link offset )
    OVER +                 ( link next-link )              
    SWAP DUP R@ SWAP - 8 - ( next-link link addr-link-8 )
    DUP 4 MOD              ( next-link link offset f )  \ adjust offset since effect of prefect operation of PC
    ABORT" Error: Offset isn't 32bits boundary aligned."
    DUP 01FFFFFF > OVER -02000000 < OR ( next-link link offset f )
    ABORT" Error: Offset isn't in the rage between (+32M-1) and -32M."
    SWAP DUP @ $FF000000 forthAND  ( next-link offset link offset' )   \ get other field in the cuurent resolving address
    ROT 2 RSHIFT $00FFFFFF forthAND +  ( next-link link offset )       \ resolve branch instruction
    SWAP !                                        \ resolve current forward reference
    R> SWAP                                       \ get resolved address from R for loop
  LOOP 
  DROP DROP 
  ;                                               

: LABEL: ( -- )
  >IN @ >R                               \ save interpreter pointer
  BL WORD FIND
    IF HERE-I SWAP >BODY RESOLVE R> DROP \ resolve all related reference
    ELSE
      DROP                               \ drop string
      R> >IN !                           \ restore word pointer
      HERE-I CONSTANT
      DOES>  ( -- n )
        @
    THEN   
  ;

\ Assembler Variables
VARIABLE OPERAND#                OPERAND# OFF
VARIABLE REG#                    REG# OFF
VARIABLE PSR_REG#                PSR_REG# OFF
VARIABLE CONDITION#              CONDITION# OFF
VARIABLE SET#                    SET# OFF
VARIABLE SHIFT_REG#              SHIFT_REG# OFF
VARIABLE SHIFT_EXPRESSION#       SHIFT_EXPRESSION# OFF
VARIABLE EXPRESSION#             EXPRESSION# OFF
VARIABLE PUBWL_WORD#             PUBWL_WORD# OFF
VARIABLE GROUP#                  GROUP# OFF
VARIABLE OLD_SP#                 OLD_SP# OFF

: CLEAR_ALL# ( -- )
  OPERAND# OFF
  REG# OFF
  PSR_REG# OFF
  CONDITION# OFF
  SET# OFF
  SHIFT_REG# OFF
  SHIFT_EXPRESSION# OFF
  EXPRESSION# OFF
  PUBWL_WORD# OFF
  GROUP# OFF
  OLD_SP# OFF
  ;

: SHOW_ALL#
  ." OPERAND# = " OPERAND# ? CR
  ." REG# = " REG# ? CR
  ." PSR_REG# = " PSR_REG# ? CR
  ." CONDITION# = " CONDITION# ? CR
  ." SET# = " SET# ? CR
  ." SHIFT_REG# = " SHIFT_REG# ? CR
  ." SHIFT_EXPRESSION# = " SHIFT_EXPRESSION# ? CR
  ." EXPRESSION# = " EXPRESSION# ? CR
  ." PUBWL_WORD# = " PUBWL_WORD# ? CR
  ." GROUP# = " GROUP# ? CR
  ." OLD_SP# = " OLD_SP# ? CR
  ;




\ compiler_Branching_Looping.f
IN-ASSEMBLER
: $NEXT ( -- )
 \ -------- ITC Version1 ---------
 \ WP, IP,            ,MOV                \ get next CFA
 \ IP, IP, 4 #        ,ADD                \ point to new CFA
 \ WP                 ,BX                 \ jump to next CFA
 \ -------- ITC Version2 ---------

\  [] PC, IP, 4 #      ,LDR                \ direct jump
   [IP+4]->PC
 
  ; 








( Registers of ARM7 eForth VM ) 
(
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
)

IN-META
: HERE-I HERE-T THERE ;

( Patch assembler )
' IMAGE   ASSEMBLER    IS IMAGE    META
' HERE-I  ASSEMBLER    IS HERE-I   META 
' ,-T     ASSEMBLER    IS ,        META