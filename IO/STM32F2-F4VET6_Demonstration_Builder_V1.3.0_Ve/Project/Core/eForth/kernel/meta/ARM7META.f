\ Copyright (c) 2001 by Blueputer Technology Inc.
\ All rights reserved 
\
\ ARM7META.F   23OCT01 created by Wuja.
\
\ ARM7eForth MetaCompiler.
\
\ (Adapted from WIN32FOR V4.2 MetaCompiler)
\ 
\ V1.00,   23OTC01WUJA,  Adapted from WIN32FOR V4.2 MetaCompiler.
\

\                 ARM7(EP7211) Memory Allocation
\ ---------------------------------------------------------------------------
\ 
\ 
\             RAM_NAME  +------------------------+  MININ+$8000
\                       |                        |
\                       |       Name Area        |
\                       |                        |
\                       |------------------------|
\                       |       Free Space       |
\                       |------------------------|
\                       |                        |
\                       |       Code Area        |
\                       |                        |
\             RAM_CODE  +------------------------+  RPP+$100
\                       |       Reserved         |
\                  RPP  +------------------------+  SPP+$1700
\                       |     Return Stack       |
\                       |      (~512 bytes)      |  
\                       +------------------------+  
\                       |  Terminal Input Buffer |
\                       |     (4096 Bytes)       |
\                  TIB  +------------------------+  SPP+$10
\                       |       Reserved         |  
\                  SPP  +------------------------+  UPP+$500
\                       |      Data Stack        |  
\                       |      (512 bytes)       |
\                       +------------------------+  UPP+$300
\                       |   User Variable Area   |
\                       |      (512 bytes)       |
\                  UPP  +------------------------+  MININT+$100
\                       |       Reserved         |
\                       +------------------------+  MININT+$2
\                       |    Boot Entry Point    |
\               MININT  +------------------------+  $60000000
\ 

\ Metacompiling initialization
EMPTY
HEX
SYS-WARNING-OFF
WARNING OFF
' NOOP IS STACK-CHECK

\ Define words in FORTH for vocanulary operations 
VOCABULARY META
VOCABULARY TARGET
VOCABULARY FORWARD
VOCABULARY TRANSITION
VOCABULARY ASSEMBLER

' FORWARD VCFA>VOC CONSTANT FORWARD-WORDLIST
' TARGET  VCFA>VOC CONSTANT TARGET-WORDLIST

: IN-META ( -- ) ONLY FORTH ALSO META ALSO DEFINITIONS ;
: IN-TRANSITION ( -- ) ONLY FORWARD ALSO TARGET ALSO TRANSITION ;
: IN-ASSEMBLER ( -- ) ONLY FORTH ALSO ASSEMBLER DEFINITIONS ;

8000 CONSTANT IMAGE_SIZE

CREATE IMAGE  IMAGE_SIZE ALLOT
IMAGE IMAGE_SIZE ERASE

\ Define words in META for metacompiling
IN-META

( Memory Constants )
$60000000 CONSTANT      MININT                 \ bottom of ARM7EF memory map
MININT IMAGE_SIZE + 1 - 
          CONSTANT      MAXINT                 \ top of ARM7EF memory map
$4    CONSTANT   CELL_SIZE                     \ size of one cell
$200  CONSTANT   USER_SIZE                     \ user area size in cells
$200  CONSTANT   RS_SIZE                       \ return stack/TIB size
$200  CONSTANT   DS_SIZE                       \ data stack size
$1000 CONSTANT   TIB_SIZE                      \ TIB size
$200  CONSTANT   USER_SIZE                     \ user variable area size
$100  CONSTANT   INIT_SIZE                     \ initialization area size
$0A   CONSTANT   =BASEE

MININT    CONSTANT MEM_BASE                    \ base of memory
MININT INIT_SIZE +
          CONSTANT =UPP                        \ base of eforth user area
=UPP USER_SIZE + DS_SIZE +
          CONSTANT =SPP                        \ bottom of data stack (SP0)
=SPP $10 + 
          CONSTANT =TIB                        \ base of T.I.B (TIB)
=SPP RS_SIZE + TIB_SIZE +          
          CONSTANT =RPP                        \ bottom of return stack (RP0)
=RPP $100 +
          CONSTANT CODE_BASE                   \ base of CODE area
MININT IMAGE_SIZE +
          CONSTANT NAME_BASE                   \ base of NAME area
$EB000000 CONSTANT =CALL

( ARM ELF Header Defintion )
: 4TOW,  ( n1 n2 n3 n4 -- n )
  18 LSHIFT
  SWAP 10 LSHIFT OR
  SWAP 08 LSHIFT OR
  SWAP OR , ;

: 2TOW,  ( n1 n2 -- n )
  10 LSHIFT
  SWAP OR , ;
  

\ ELF Header Defintion
B0 CONSTANT HEADER_SIZE 
CREATE ELF_HEADER
7F CHAR E CHAR L CHAR F 4TOW,            \ (00) 0X7F,'E','L','F' -- EI_MAG0~3
01 01 01 00 4TOW,                        \ (04) EI_CLASS, EI_DATA, EI_VERSION, EI_PAD
00 00 00 00 4TOW,                        \ (08) EI_PAD...
00 00 00 00 4TOW,                        \ (0C) EI_PAD..., EI_NIDENT
02 28 2TOW,                              \ (10) ET_EXEC, EM_ARM  
01 ,                                     \ (14) EV_CURRENT
MEM_BASE ,                               \ (18) Entry Point under ANGEL
34 ,                                     \ (1C) E_PHOFF               
54 ,                                     \ (20) E_SHOFF               
02 ,                                     \ (24) E_FLAGS
34 20 2TOW,                              \ (28) E_EHSIZE, E_PHENTSIZE 
01 28 2TOW,                              \ (2C) E_PHNUM, E_SHENTSIZE  
02 01 2TOW,                              \ (30) E_SHNUM, E_SHSTRNDX   
\ Program Header Defintion (Offset=$34)
01 ,                                     \ (34) P_TYPE = PT_LOAD
HEADER_SIZE ,                            \ (38) P_OFFSET             
MEM_BASE ,                               \ (3C) P_VADDR
00 ,                                     \ (40) P_PADDR
IMAGE_SIZE ,                             \ (44) P_FILESZ              
IMAGE_SIZE ,                             \ (48) P_MEMSZ                
05 ,                                     \ (4C) P_FLAGS = PF_X+PF_R
04 ,                                     \ (50) P_ALIGN
\ Dummy Section Header Table(#0) Defition (Offset=$54)
00 ,                                     \ (54) SH_NAME
00 ,                                     \ (58) SH_TYPE
00 ,                                     \ (5C) SH_FLAGS
00 ,                                     \ (60) SH_ADDR
00 ,                                     \ (64) SH_OFFSET
00 ,                                     \ (68) SH_SIZE
00 ,                                     \ (6C) SH_LINK
00 ,                                     \ (70) SH_INFO
00 ,                                     \ (74) SH_ADDRALIGN
00 ,                                     \ (78) SH_ENTSIZE
\ Dummy Section Header Table(#1) Defition (Offset=$7C)
00 ,                                     \ (7C) SH_NAME
03 ,                                     \ (80) SH_TYPE(=SHT_STRTAB)
00 ,                                     \ (84) SH_FLAGS
00 ,                                     \ (88) SH_ADDR
A4 ,                                     \ (8C) SH_OFFSET
0C ,                                     \ (90) SH_SIZE
00 ,                                     \ (94) SH_LINK
00 ,                                     \ (98) SH_INFO
00 ,                                     \ (9C) SH_ADDRALIGN
00 ,                                     \ (A0) SH_ENTSIZE
\ Dummy String Table Definition (Offset=$A4)
CHAR A CHAR R CHAR M CHAR 7 4TOW,        \ (A4) 'ARM7'
CHAR E CHAR F CHAR V CHAR 1 4TOW,        \ (A8) 'EFV1'
CHAR . CHAR 0 CHAR 0 0      4TOW,        \ (AC) '.00 '

\ ASCII PATTERN TABLE ( 8 * 256 = 2048(0X800) )
800 CONSTANT PATTERN_SIZE
CREATE ASCII_PATTERN_TABLE
00 C,  00 C,  00 C,  00 C,  00 C,  00 C,  00 C,  00 C,	\ 00
7e C,  81 C,  a5 C,  81 C,  bd C,  99 C,  81 C,  7e C,	\ 01
7c C,  fe C,  d6 C,  ba C,  c6 C,  fe C,  7c C,  00 C,	\ 02
c6 C,  ee C,  fe C,  fe C,  7c C,  38 C,  10 C,  00 C,	\ 03
10 C,  38 C,  7c C,  fe C,  7c C,  38 C,  10 C,  00 C,	\ 04
10 C,  38 C,  10 C,  ee C,  ee C,  10 C,  38 C,  00 C,	\ 05
38 C,  7c C,  fe C,  fe C,  6c C,  10 C,  38 C,  00 C,	\ 06
00 C,  18 C,  3c C,  7e C,  3c C,  18 C,  00 C,  00 C,	\ 07
ff C,  e7 C,  c3 C,  81 C,  c3 C,  e7 C,  ff C,  ff C,	\ 08
00 C,  18 C,  3c C,  66 C,  66 C,  3c C,  18 C,  00 C,	\ 09
ff C,  e7 C,  c3 C,  99 C,  99 C,  c3 C,  e7 C,  ff C,	\ 0A
1e C,  0e C,  1e C,  36 C,  78 C,  cc C,  cc C,  78 C,	\ 0B
7e C,  c3 C,  c3 C,  7e C,  18 C,  7e C,  18 C,  18 C,	\ 0C
1e C,  1a C,  1e C,  18 C,  18 C,  70 C,  f0 C,  60 C,	\ 0D
3e C,  3e C,  36 C,  36 C,  f6 C,  66 C,  1e C,  0c C,	\ 0E
db C,  3c C,  66 C,  e7 C,  66 C,  3c C,  db C,  00 C,	\ 0F
80 C,  c0 C,  f0 C,  f8 C,  f0 C,  c0 C,  80 C,  00 C,	\ 10
02 C,  06 C,  1e C,  3e C,  1e C,  06 C,  02 C,  00 C,	\ 11
18 C,  3c C,  7e C,  18 C,  7e C,  3c C,  18 C,  00 C,	\ 12
66 C,  66 C,  66 C,  66 C,  66 C,  00 C,  66 C,  00 C,	\ 13
7f C,  db C,  7b C,  3b C,  1b C,  1b C,  1b C,  00 C,	\ 14
3c C,  66 C,  38 C,  6c C,  6c C,  38 C,  cc C,  78 C,	\ 15
00 C,  00 C,  00 C,  00 C,  fe C,  fe C,  fe C,  00 C,	\ 16
18 C,  3c C,  7e C,  18 C,  7e C,  3c C,  18 C,  7e C,	\ 17
18 C,  3c C,  7e C,  18 C,  18 C,  18 C,  18 C,  00 C,	\ 18
18 C,  18 C,  18 C,  18 C,  7e C,  3c C,  18 C,  00 C,	\ 19
00 C,  18 C,  1c C,  fe C,  1c C,  18 C,  00 C,  00 C,	\ 1A
00 C,  30 C,  70 C,  fe C,  70 C,  30 C,  00 C,  00 C,	\ 1B
00 C,  00 C,  c0 C,  c0 C,  c0 C,  fe C,  00 C,  00 C,	\ 1C
00 C,  24 C,  66 C,  ff C,  66 C,  24 C,  00 C,  00 C,	\ 1D
00 C,  10 C,  38 C,  7c C,  7c C,  fe C,  00 C,  00 C,	\ 1E
00 C,  fe C,  7c C,  7c C,  38 C,  10 C,  00 C,  00 C,	\ 1F
00 C,  00 C,  00 C,  00 C,  00 C,  00 C,  00 C,  00 C,	\ 20
18 C,  3c C,  3c C,  18 C,  18 C,  00 C,  18 C,  00 C,	\ 21
6c C,  6c C,  6c C,  00 C,  00 C,  00 C,  00 C,  00 C,	\ 22
6c C,  6c C,  fe C,  6c C,  fe C,  6c C,  6c C,  00 C,	\ 23
18 C,  7e C,  c0 C,  7c C,  06 C,  fc C,  18 C,  00 C,	\ 24
00 C,  c6 C,  0c C,  18 C,  30 C,  60 C,  c6 C,  00 C,	\ 25
38 C,  6c C,  38 C,  76 C,  cc C,  cc C,  76 C,  00 C,	\ 26
18 C,  18 C,  30 C,  00 C,  00 C,  00 C,  00 C,  00 C,	\ 27
18 C,  30 C,  60 C,  60 C,  60 C,  30 C,  18 C,  00 C,	\ 28
60 C,  30 C,  18 C,  18 C,  18 C,  30 C,  60 C,  00 C,	\ 29
00 C,  ee C,  7c C,  fe C,  7c C,  ee C,  00 C,  00 C,	\ 2A
00 C,  18 C,  18 C,  7e C,  18 C,  18 C,  00 C,  00 C,	\ 2B
00 C,  00 C,  00 C,  00 C,  18 C,  18 C,  30 C,  00 C,	\ 2C
00 C,  00 C,  00 C,  fe C,  00 C,  00 C,  00 C,  00 C,	\ 2D
00 C,  00 C,  00 C,  00 C,  00 C,  38 C,  38 C,  00 C,	\ 2E
06 C,  0c C,  18 C,  30 C,  60 C,  c0 C,  80 C,  00 C,	\ 2F
7c C,  c6 C,  ce C,  de C,  f6 C,  e6 C,  7c C,  00 C,	\ 30 (0)
18 C,  78 C,  18 C,  18 C,  18 C,  18 C,  7e C,  00 C,	\ 31 (1)
7c C,  c6 C,  0c C,  18 C,  30 C,  66 C,  fe C,  00 C,	\ 32 (2)
7c C,  c6 C,  06 C,  3c C,  06 C,  c6 C,  7c C,  00 C,	\ 33 (3)
0c C,  1c C,  3c C,  6c C,  fe C,  0c C,  0c C,  00 C,	\ 34 (4)
fe C,  c0 C,  fc C,  06 C,  06 C,  c6 C,  7c C,  00 C,	\ 35 (5)
7c C,  c6 C,  c0 C,  fc C,  c6 C,  c6 C,  7c C,  00 C,	\ 36 (6)
fe C,  c6 C,  06 C,  0c C,  18 C,  18 C,  18 C,  00 C,	\ 37 (7)
7c C,  c6 C,  c6 C,  7c C,  c6 C,  c6 C,  7c C,  00 C,	\ 38 (8)
7c C,  c6 C,  c6 C,  7e C,  06 C,  c6 C,  7c C,  00 C,	\ 39 (9)
00 C,  1c C,  1c C,  00 C,  00 C,  1c C,  1c C,  00 C,	\ 3A (:)
00 C,  18 C,  18 C,  00 C,  00 C,  18 C,  18 C,  30 C,	\ 3B (;)
0c C,  18 C,  30 C,  60 C,  30 C,  18 C,  0c C,  00 C,	\ 3C
00 C,  00 C,  fe C,  00 C,  00 C,  fe C,  00 C,  00 C,	\ 3D
60 C,  30 C,  18 C,  0c C,  18 C,  30 C,  60 C,  00 C,	\ 3E
7c C,  c6 C,  06 C,  0c C,  18 C,  00 C,  18 C,  00 C,	\ 3F
7c C,  c6 C,  c6 C,  de C,  dc C,  c0 C,  7e C,  00 C,	\ 40
38 C,  6c C,  c6 C,  c6 C,  fe C,  c6 C,  c6 C,  00 C,	\ 41 (A)
fc C,  66 C,  66 C,  7c C,  66 C,  66 C,  fc C,  00 C,	\ 42
3c C,  66 C,  c0 C,  c0 C,  c0 C,  66 C,  3c C,  00 C,	\ 43
f8 C,  6c C,  66 C,  66 C,  66 C,  6c C,  f8 C,  00 C,	\ 44
fe C,  c2 C,  c0 C,  f8 C,  c0 C,  c2 C,  fe C,  00 C,	\ 45
fe C,  62 C,  60 C,  7c C,  60 C,  60 C,  f0 C,  00 C,	\ 46
7c C,  c6 C,  c0 C,  c0 C,  de C,  c6 C,  7c C,  00 C,	\ 47
c6 C,  c6 C,  c6 C,  fe C,  c6 C,  c6 C,  c6 C,  00 C,	\ 48
3c C,  18 C,  18 C,  18 C,  18 C,  18 C,  3c C,  00 C,	\ 49
3c C,  18 C,  18 C,  18 C,  d8 C,  d8 C,  70 C,  00 C,	\ 4A
c6 C,  cc C,  d8 C,  f0 C,  d8 C,  cc C,  c6 C,  00 C,	\ 4B
f0 C,  60 C,  60 C,  60 C,  60 C,  62 C,  fe C,  00 C,	\ 4C
c6 C,  ee C,  fe C,  d6 C,  d6 C,  c6 C,  c6 C,  00 C,	\ 4D
c6 C,  e6 C,  e6 C,  f6 C,  de C,  ce C,  c6 C,  00 C,	\ 4E
7c C,  c6 C,  c6 C,  c6 C,  c6 C,  c6 C,  7c C,  00 C,	\ 4F
fc C,  66 C,  66 C,  7c C,  60 C,  60 C,  f0 C,  00 C,	\ 50
7c C,  c6 C,  c6 C,  c6 C,  c6 C,  d6 C,  7c C,  06 C,	\ 51
fc C,  c6 C,  c6 C,  fc C,  d8 C,  cc C,  c6 C,  00 C,	\ 52
7c C,  c6 C,  c0 C,  7c C,  06 C,  c6 C,  7c C,  00 C,	\ 53
7e C,  5a C,  18 C,  18 C,  18 C,  18 C,  3c C,  00 C,	\ 54
c6 C,  c6 C,  c6 C,  c6 C,  c6 C,  c6 C,  7c C,  00 C,	\ 55
c6 C,  c6 C,  c6 C,  c6 C,  6c C,  38 C,  10 C,  00 C,	\ 56
c6 C,  c6 C,  d6 C,  d6 C,  fe C,  ee C,  c6 C,  00 C,	\ 57
c6 C,  6c C,  38 C,  38 C,  38 C,  6c C,  c6 C,  00 C,	\ 58
66 C,  66 C,  66 C,  3c C,  18 C,  18 C,  3c C,  00 C,	\ 59
fe C,  86 C,  0c C,  18 C,  30 C,  62 C,  fe C,  00 C,	\ 5a
7c C,  60 C,  60 C,  60 C,  60 C,  60 C,  7c C,  00 C,	\ 5b
c0 C,  60 C,  30 C,  18 C,  0c C,  06 C,  02 C,  00 C,	\ 5c
7c C,  0c C,  0c C,  0c C,  0c C,  0c C,  7c C,  00 C,	\ 5d
10 C,  38 C,  6c C,  c6 C,  00 C,  00 C,  00 C,  00 C,	\ 5e
00 C,  00 C,  00 C,  00 C,  00 C,  00 C,  00 C,  ff C,	\ 5f
30 C,  30 C,  18 C,  00 C,  00 C,  00 C,  00 C,  00 C,	\ 60
00 C,  00 C,  78 C,  0c C,  7c C,  cc C,  7e C,  00 C,	\ 61
e0 C,  60 C,  7c C,  66 C,  66 C,  66 C,  fc C,  00 C,	\ 62
00 C,  00 C,  7c C,  c6 C,  c0 C,  c6 C,  7c C,  00 C,	\ 63
1c C,  0c C,  7c C,  cc C,  cc C,  cc C,  7e C,  00 C,	\ 64
00 C,  00 C,  7c C,  c6 C,  fe C,  c0 C,  7c C,  00 C,	\ 65
1c C,  36 C,  30 C,  fc C,  30 C,  30 C,  78 C,  00 C,	\ 66
00 C,  00 C,  76 C,  ce C,  c6 C,  7e C,  06 C,  7c C,	\ 67
e0 C,  60 C,  7c C,  66 C,  66 C,  66 C,  e6 C,  00 C,	\ 68
18 C,  00 C,  38 C,  18 C,  18 C,  18 C,  3c C,  00 C,	\ 69
0c C,  00 C,  1c C,  0c C,  0c C,  0c C,  cc C,  78 C,	\ 6a
e0 C,  60 C,  66 C,  6c C,  78 C,  6c C,  e6 C,  00 C,	\ 6b
18 C,  18 C,  18 C,  18 C,  18 C,  18 C,  1c C,  00 C,	\ 6c
00 C,  00 C,  6c C,  fe C,  d6 C,  d6 C,  c6 C,  00 C,	\ 6d
00 C,  00 C,  dc C,  66 C,  66 C,  66 C,  66 C,  00 C,	\ 6e
00 C,  00 C,  7c C,  c6 C,  c6 C,  c6 C,  7c C,  00 C,	\ 6f
00 C,  00 C,  dc C,  66 C,  66 C,  7c C,  60 C,  f0 C,	\ 70
00 C,  00 C,  76 C,  cc C,  cc C,  7c C,  0c C,  1e C,	\ 71
00 C,  00 C,  dc C,  66 C,  60 C,  60 C,  f0 C,  00 C,	\ 72
00 C,  00 C,  7c C,  c0 C,  7c C,  06 C,  7c C,  00 C,	\ 73
30 C,  30 C,  fc C,  30 C,  30 C,  36 C,  1c C,  00 C,	\ 74
00 C,  00 C,  cc C,  cc C,  cc C,  cc C,  76 C,  00 C,	\ 75
00 C,  00 C,  c6 C,  c6 C,  6c C,  38 C,  10 C,  00 C,	\ 76
00 C,  00 C,  c6 C,  c6 C,  d6 C,  fe C,  6c C,  00 C,	\ 77
00 C,  00 C,  c6 C,  6c C,  38 C,  6c C,  c6 C,  00 C,	\ 78
00 C,  00 C,  c6 C,  c6 C,  ce C,  76 C,  06 C,  7c C,	\ 79
00 C,  00 C,  fc C,  98 C,  30 C,  64 C,  fc C,  00 C,	\ 7a
0e C,  18 C,  18 C,  70 C,  18 C,  18 C,  0e C,  00 C,	\ 7b
18 C,  18 C,  18 C,  00 C,  18 C,  18 C,  18 C,  00 C,	\ 7c
70 C,  18 C,  18 C,  0e C,  18 C,  18 C,  70 C,  00 C,	\ 7d
76 C,  dc C,  00 C,  00 C,  00 C,  00 C,  00 C,  00 C,	\ 7e
00 C,  10 C,  38 C,  38 C,  6c C,  6c C,  fe C,  00 C,	\ 7f
3c C,  66 C,  c0 C,  66 C,  3c C,  18 C,  cc C,  78 C,	\ 80
00 C,  c6 C,  00 C,  c6 C,  c6 C,  ce C,  76 C,  00 C,	\ 81
0e C,  00 C,  7c C,  c6 C,  fe C,  c0 C,  7c C,  00 C,	\ 82
7c C,  c6 C,  78 C,  0c C,  7c C,  cc C,  7e C,  00 C,	\ 83
c6 C,  00 C,  78 C,  0c C,  7c C,  cc C,  7e C,  00 C,	\ 84
e0 C,  00 C,  78 C,  0c C,  7c C,  cc C,  7e C,  00 C,	\ 85
38 C,  38 C,  78 C,  0c C,  7c C,  cc C,  7e C,  00 C,	\ 86
00 C,  00 C,  7c C,  c0 C,  7c C,  18 C,  6c C,  38 C,	\ 87
7c C,  c6 C,  7c C,  c6 C,  fe C,  c0 C,  7c C,  00 C,	\ 88
c6 C,  00 C,  7c C,  c6 C,  fe C,  c0 C,  7c C,  00 C,	\ 89
e0 C,  00 C,  7c C,  c6 C,  fe C,  c0 C,  7c C,  00 C,	\ 8a
66 C,  00 C,  38 C,  18 C,  18 C,  18 C,  3c C,  00 C,	\ 8b
7c C,  c6 C,  38 C,  18 C,  18 C,  18 C,  3c C,  00 C,	\ 8c
e0 C,  00 C,  38 C,  18 C,  18 C,  18 C,  3c C,  00 C,	\ 8d
c6 C,  38 C,  6c C,  c6 C,  fe C,  c6 C,  c6 C,  00 C,	\ 8e
38 C,  38 C,  00 C,  7c C,  c6 C,  fe C,  c6 C,  00 C,	\ 8f
0e C,  00 C,  fe C,  c0 C,  f8 C,  c0 C,  fe C,  00 C,	\ 90
00 C,  00 C,  6c C,  9a C,  7e C,  d8 C,  6e C,  00 C,	\ 91
7e C,  d8 C,  d8 C,  fe C,  d8 C,  d8 C,  de C,  00 C,	\ 92
7c C,  c6 C,  00 C,  7c C,  c6 C,  c6 C,  7c C,  00 C,	\ 93
00 C,  c6 C,  00 C,  7c C,  c6 C,  c6 C,  7c C,  00 C,	\ 94
00 C,  e0 C,  00 C,  7c C,  c6 C,  c6 C,  7c C,  00 C,	\ 95
7c C,  c6 C,  00 C,  c6 C,  c6 C,  ce C,  76 C,  00 C,	\ 96
00 C,  e0 C,  00 C,  c6 C,  c6 C,  ce C,  76 C,  00 C,	\ 97
00 C,  c6 C,  00 C,  c6 C,  ce C,  76 C,  06 C,  7c C,	\ 98
c6 C,  38 C,  6c C,  c6 C,  c6 C,  6c C,  38 C,  00 C,	\ 99
c6 C,  00 C,  c6 C,  c6 C,  c6 C,  c6 C,  7c C,  00 C,	\ 9a
00 C,  18 C,  7e C,  d8 C,  d8 C,  7e C,  18 C,  00 C,	\ 9b
38 C,  6c C,  60 C,  f0 C,  66 C,  f6 C,  6c C,  00 C,	\ 9c
c3 C,  66 C,  3c C,  7e C,  18 C,  3c C,  18 C,  00 C,	\ 9d
fc C,  c6 C,  fc C,  cc C,  de C,  cc C,  ce C,  00 C,	\ 9e
0c C,  1e C,  18 C,  7e C,  18 C,  18 C,  d8 C,  70 C,	\ 9f
0e C,  00 C,  78 C,  0c C,  7c C,  cc C,  7e C,  00 C,	\ a0
1c C,  00 C,  38 C,  18 C,  18 C,  18 C,  3c C,  00 C,	\ a1
00 C,  0e C,  00 C,  7c C,  c6 C,  c6 C,  7c C,  00 C,	\ a2
00 C,  0e C,  00 C,  cc C,  cc C,  dc C,  76 C,  00 C,	\ a3
00 C,  fc C,  00 C,  bc C,  66 C,  66 C,  e6 C,  00 C,	\ a4
fe C,  00 C,  c6 C,  e6 C,  f6 C,  ce C,  c6 C,  00 C,	\ a5
38 C,  6c C,  3e C,  00 C,  7e C,  00 C,  00 C,  00 C,	\ a6
7c C,  c6 C,  7c C,  00 C,  7c C,  00 C,  00 C,  00 C,	\ a7
18 C,  00 C,  18 C,  30 C,  60 C,  66 C,  3c C,  00 C,	\ a8
00 C,  00 C,  00 C,  7c C,  60 C,  60 C,  00 C,  00 C,	\ a9
00 C,  00 C,  00 C,  7c C,  0c C,  0c C,  00 C,  00 C,	\ aa
c0 C,  cc C,  d8 C,  30 C,  7c C,  36 C,  0c C,  3e C,	\ ab
c0 C,  cc C,  d8 C,  30 C,  6c C,  3c C,  7e C,  0c C,	\ ac
18 C,  00 C,  18 C,  18 C,  3c C,  3c C,  18 C,  00 C,	\ ad
00 C,  36 C,  6c C,  d8 C,  6c C,  36 C,  00 C,  00 C,	\ ae
00 C,  d8 C,  6c C,  36 C,  6c C,  d8 C,  00 C,  00 C,	\ af
22 C,  88 C,  22 C,  88 C,  22 C,  88 C,  22 C,  88 C,	\ b0
55 C,  aa C,  55 C,  aa C,  55 C,  aa C,  55 C,  aa C,	\ b1
dd C,  77 C,  dd C,  77 C,  dd C,  77 C,  dd C,  77 C,	\ b2
18 C,  18 C,  18 C,  18 C,  18 C,  18 C,  18 C,  18 C,	\ b3
18 C,  18 C,  18 C,  18 C,  f8 C,  18 C,  18 C,  18 C,	\ b4
18 C,  18 C,  f8 C,  18 C,  f8 C,  18 C,  18 C,  18 C,	\ b5
36 C,  36 C,  36 C,  36 C,  f6 C,  36 C,  36 C,  36 C,	\ b6
00 C,  00 C,  00 C,  00 C,  fe C,  36 C,  36 C,  36 C,	\ b7
00 C,  00 C,  f8 C,  18 C,  f8 C,  18 C,  18 C,  18 C,	\ b8
36 C,  36 C,  f6 C,  06 C,  f6 C,  36 C,  36 C,  36 C,	\ b9
36 C,  36 C,  36 C,  36 C,  36 C,  36 C,  36 C,  36 C,	\ ba
00 C,  00 C,  fe C,  06 C,  f6 C,  36 C,  36 C,  36 C,	\ bb
36 C,  36 C,  f6 C,  06 C,  fe C,  00 C,  00 C,  00 C,	\ bc
36 C,  36 C,  36 C,  36 C,  fe C,  00 C,  00 C,  00 C,	\ bd
18 C,  18 C,  f8 C,  18 C,  f8 C,  00 C,  00 C,  00 C,	\ be
00 C,  00 C,  00 C,  00 C,  f8 C,  18 C,  18 C,  18 C,	\ bf
18 C,  18 C,  18 C,  18 C,  1f C,  00 C,  00 C,  00 C,	\ c0
18 C,  18 C,  18 C,  18 C,  ff C,  00 C,  00 C,  00 C,	\ c1
00 C,  00 C,  00 C,  00 C,  ff C,  18 C,  18 C,  18 C,	\ c2
18 C,  18 C,  18 C,  18 C,  1f C,  18 C,  18 C,  18 C,	\ c3
00 C,  00 C,  00 C,  00 C,  ff C,  00 C,  00 C,  00 C,	\ c4
18 C,  18 C,  18 C,  18 C,  ff C,  18 C,  18 C,  18 C,	\ c5
18 C,  18 C,  1f C,  18 C,  1f C,  18 C,  18 C,  18 C,	\ c6
36 C,  36 C,  36 C,  36 C,  37 C,  36 C,  36 C,  36 C,	\ c7
36 C,  36 C,  37 C,  30 C,  3f C,  00 C,  00 C,  00 C,	\ c8
00 C,  00 C,  3f C,  30 C,  37 C,  36 C,  36 C,  36 C,	\ c9
36 C,  36 C,  f7 C,  00 C,  ff C,  00 C,  00 C,  00 C,	\ ca
00 C,  00 C,  ff C,  00 C,  f7 C,  36 C,  36 C,  36 C,	\ cb
36 C,  36 C,  37 C,  30 C,  37 C,  36 C,  36 C,  36 C,	\ cc
00 C,  00 C,  ff C,  00 C,  ff C,  00 C,  00 C,  00 C,	\ cd
36 C,  36 C,  f7 C,  00 C,  f7 C,  36 C,  36 C,  36 C,	\ ce
18 C,  18 C,  ff C,  00 C,  ff C,  00 C,  00 C,  00 C,	\ cf
36 C,  36 C,  36 C,  36 C,  ff C,  00 C,  00 C,  00 C,	\ d0
00 C,  00 C,  ff C,  00 C,  ff C,  18 C,  18 C,  18 C,	\ d1
00 C,  00 C,  00 C,  00 C,  ff C,  36 C,  36 C,  36 C,	\ d2
36 C,  36 C,  36 C,  36 C,  3f C,  00 C,  00 C,  00 C,	\ d3
18 C,  18 C,  1f C,  18 C,  1f C,  00 C,  00 C,  00 C,	\ d4
00 C,  00 C,  1f C,  18 C,  1f C,  18 C,  18 C,  18 C,	\ d5
00 C,  00 C,  00 C,  00 C,  3f C,  36 C,  36 C,  36 C,	\ d6
36 C,  36 C,  36 C,  36 C,  ff C,  36 C,  36 C,  36 C,	\ d7
18 C,  18 C,  ff C,  18 C,  ff C,  18 C,  18 C,  18 C,	\ d8
18 C,  18 C,  18 C,  18 C,  f8 C,  00 C,  00 C,  00 C,	\ d9
00 C,  00 C,  00 C,  00 C,  1f C,  18 C,  18 C,  18 C,	\ da
ff C,  ff C,  ff C,  ff C,  ff C,  ff C,  ff C,  ff C,	\ db
00 C,  00 C,  00 C,  00 C,  ff C,  ff C,  ff C,  ff C,	\ dc
f0 C,  f0 C,  f0 C,  f0 C,  f0 C,  f0 C,  f0 C,  f0 C,	\ dd
0f C,  0f C,  0f C,  0f C,  0f C,  0f C,  0f C,  0f C,	\ de
ff C,  ff C,  ff C,  ff C,  00 C,  00 C,  00 C,  00 C,	\ df
00 C,  00 C,  66 C,  dc C,  d8 C,  dc C,  66 C,  00 C,	\ e0
00 C,  78 C,  cc C,  f8 C,  cc C,  c6 C,  cc C,  00 C,	\ e1
00 C,  fe C,  62 C,  60 C,  60 C,  60 C,  e0 C,  00 C,	\ e2
00 C,  fe C,  6c C,  6c C,  6c C,  6c C,  6c C,  00 C,	\ e3
fe C,  c6 C,  60 C,  30 C,  60 C,  c6 C,  fe C,  00 C,	\ e4
00 C,  7e C,  d8 C,  cc C,  cc C,  d8 C,  70 C,  00 C,	\ e5
00 C,  66 C,  66 C,  66 C,  66 C,  7c C,  c0 C,  00 C,	\ e6
00 C,  76 C,  dc C,  18 C,  18 C,  18 C,  38 C,  00 C,	\ e7
fe C,  38 C,  6c C,  c6 C,  6c C,  38 C,  fe C,  00 C,	\ e8
38 C,  6c C,  c6 C,  fe C,  c6 C,  6c C,  38 C,  00 C,	\ e9
38 C,  6c C,  c6 C,  c6 C,  6c C,  6c C,  ee C,  00 C,	\ ea
3e C,  60 C,  38 C,  66 C,  c6 C,  cc C,  78 C,  00 C,	\ eb
00 C,  00 C,  7e C,  db C,  db C,  7e C,  00 C,  00 C,	\ ec
06 C,  7c C,  de C,  f6 C,  e6 C,  7c C,  c0 C,  00 C,	\ ed
38 C,  60 C,  c0 C,  f8 C,  c0 C,  60 C,  38 C,  00 C,	\ ee
7c C,  c6 C,  c6 C,  c6 C,  c6 C,  c6 C,  c6 C,  00 C,	\ ef
00 C,  fe C,  00 C,  fe C,  00 C,  fe C,  00 C,  00 C,	\ f0
18 C,  18 C,  7e C,  18 C,  18 C,  00 C,  7e C,  00 C,	\ f1
30 C,  18 C,  0c C,  18 C,  30 C,  00 C,  7e C,  00 C,	\ f2
0c C,  18 C,  30 C,  18 C,  0c C,  00 C,  7e C,  00 C,	\ f3
0c C,  1e C,  18 C,  18 C,  18 C,  18 C,  18 C,  18 C,	\ f4
18 C,  18 C,  18 C,  18 C,  18 C,  78 C,  30 C,  00 C,	\ f5
00 C,  00 C,  18 C,  00 C,  7e C,  00 C,  18 C,  00 C,	\ f6
00 C,  76 C,  dc C,  00 C,  76 C,  dc C,  00 C,  00 C,	\ f7
7c C,  c6 C,  c6 C,  7c C,  00 C,  00 C,  00 C,  00 C,	\ f8
00 C,  00 C,  00 C,  18 C,  18 C,  00 C,  00 C,  00 C,	\ f9
00 C,  00 C,  00 C,  00 C,  18 C,  00 C,  00 C,  00 C,	\ fa
1f C,  18 C,  18 C,  18 C,  f8 C,  38 C,  18 C,  00 C,	\ fb
d8 C,  6c C,  6c C,  6c C,  00 C,  00 C,  00 C,  00 C,	\ fc
70 C,  d8 C,  30 C,  f8 C,  00 C,  00 C,  00 C,  00 C,	\ fd
00 C,  00 C,  7c C,  7c C,  7c C,  7c C,  00 C,  00 C,	\ fe
00 C,  00 C,  00 C,  00 C,  00 C,  00 C,  00 C,  00 C,  \ ff

\ ASCII BIG PATTERN TABLE ( 32 * 256 = 8192 (0X2000) )
2000 CONSTANT BIG_PATTERN_SIZE
CREATE BIG_PATTERN_TABLE  BIG_PATTERN_SIZE ALLOT 
BIG_PATTERN_TABLE BIG_PATTERN_SIZE ERASE

CREATE PATTERN_BUFFER 4 ALLOT
CREATE BIG_PATTERN
88 C, 78 C, 87 C, 77 C,  
  
: CREATE_BYTE ( byte -- )
  4 0 DO
    4 /MOD SWAP BIG_PATTERN + C@
    PATTERN_BUFFER 3 I - + C!
  LOOP DROP ;

: CREATE_PATTERN ( -- )
  100 0 DO
    8 0 DO
      ASCII_PATTERN_TABLE J 8 * + I + C@
      CREATE_BYTE
      PATTERN_BUFFER
      BIG_PATTERN_TABLE J 20 * + I 4 * + 
      4 CMOVE
    LOOP
  LOOP ;        
  
CREATE_PATTERN  

VARIABLE FILE_HANDLE
: WRITE_AXF_FILE
  S" ARM7EF.AXF" R/W CREATE-FILE
  ABORT" Create file error."
  FILE_HANDLE !
  ELF_HEADER HEADER_SIZE FILE_HANDLE @ WRITE-FILE
  ABORT" Write file error."
  IMAGE IMAGE_SIZE FILE_HANDLE @ WRITE-FILE
  ABORT" Write file error."
  FILE_HANDLE @ CLOSE-FILE
  ABORT" Close file error."
  ;

: WRITE_BIN_FILE
  S" ARM7EF.BIN" R/W CREATE-FILE
  ABORT" Create file error."
  FILE_HANDLE !
  IMAGE IMAGE_SIZE FILE_HANDLE @ WRITE-FILE
  ABORT" Write file error."
  ASCII_PATTERN_TABLE PATTERN_SIZE FILE_HANDLE @ WRITE-FILE
  ABORT" Write file error."
  BIG_PATTERN_TABLE BIG_PATTERN_SIZE FILE_HANDLE @ WRITE-FILE
  ABORT" Write file error."
  FILE_HANDLE @ CLOSE-FILE
  ABORT" Close file error."
  ;

\ eForth Builder Variabler
VARIABLE LINKK  0 LINKK !                      \ initial link pointer

( Memory access words )
VARIABLE CP-T    
CODE_BASE CP-T !                   \ initialize target code dictionary point

: ORG     ( taddr -- )       CP-T !   ;

: THERE   ( taddr -- addr )  MEM_BASE - IMAGE +  ;
: C@-T    ( taddr -- c )     THERE C@ ;
: W@-T    ( taddr -- w )     THERE w@ ;
: @-T     ( taddr -- n )     THERE @  ;
: C!-T    ( c taddr -- )     THERE C! ;
: W!-T    ( w taddr -- )     THERE w! ;
: !-T     ( n taddr -- )     THERE !  ;
: HERE-T  ( -- taddr )       CP-T @   ;
: ALLOT-T ( n -- )           CP-T +!  ;
: C,-T    ( c -- )           HERE-T C!-T 1 CP-T +! ;
: W,-T    ( w -- )           DUP C,-T $FF /  C,-T  ;
: ,-T     ( n -- )           HERE-T !-T 4 CP-T +!  ;
: S,-T    ( addr len -- )    0 ?DO COUNT C,-T LOOP DROP ;
: ALIGN-T ( -- )             HERE-T ALIGNED HERE-T - ALLOT-T ;
: '-T     ( -- a )           ' ;

( Including Assembler )
IN-ASSEMBLER
FLOAD ARM7ASM.F

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

IN-META

( Define meta branching constructs )
: ?CONDITION TRUE - ABORT" Conditionals not paired" ;

: ?>MARK    ( -- f addr ) TRUE HERE-T 0 ,-T ;                  \ forward reference
: ?>RESOLVE ( f addr -- ) HERE-T SWAP !-T ?CONDITION ;         \ resolve forward reference
: ?<MARK    ( -- f addr ) TRUE HERE-T ;                        \ back reference
: ?<RESOLVE ( f addr -- ) ,-T ?CONDITION ;                     \ resolve backward reference

( Meta compiler forward reference linking )
VARIABLE FORWARD-LINK    0 FORWARD-LINK !

: MAKE-CODE ( pfa -- )  
    @ ,-T ;
    
: LINK-BACKWARDS ( pfa -- )
    HERE-T OVER @ ,-T SWAP ! ;
: RESOLVED? ( pfa -- f )
    CELL+ @ ;
    
: DO-FORWARD ( -- )
    DOES> 
      DUP RESOLVED?
        IF MAKE-CODE
        ELSE LINK-BACKWARDS 
        THEN
    ;
    
: (FORWARD)  ( taddr -- )
    GET-CURRENT >R
    FORWARD-WORDLIST SET-CURRENT
    CREATE
      ,  ( taddr )
      FALSE , ( resolve flag )
      HERE FORWARD-LINK @ , FORWARD-LINK !
    DO-FORWARD
    R> SET-CURRENT ;

: FORWARD: ( -- )
    0 (FORWARD) ;
    
: UNDEFINED ( -- )
    HERE-T (FORWARD) 0 ,-T ;

( Compile a code definition header )
VARIABLE LAST-T     0 LAST-T !
VARIABLE NP-T                                   
NAME_BASE NP-T !                          \ initialize target name dictionary point

: .WORD ( taddr -- )
  . SPACE >IN @ BL WORD COUNT TYPE >IN ! CR  ;

\ : .'CODE ( -- )
\   CODEE @ .HEAD CONSTANT  
\   DOES>  ( -- )
\     @ ,WORD ;

\ : .'USER  ( -- )
\   CODEE @ .HEAD CONSTANT  
\   DOES>  ( -- )
\     @ ;

: HEADER ( -- )
  ALIGN-T                                 \ force to CELL boundary
  HERE-T .WORD                            \ display cfa   
  BL WORD DUP C@                          \ get name and length of new definition 
  1F AND CELL_SIZE /                      \ length in unit CELL
  3 + CELL_SIZE * NP-T @ SWAP -           \ reserved header space
                                          \ CFA ----- NAMEE
                                          \ LFA ----- NAMEE+CELL*1
                                          \ LEX ----- NAMEE+CELL*1+3
                                          \ STRING -- NAMEE+CELL*1+4
  DUP NP-T !                              \ set name pointer
  HERE-T >R                               \ save CP-T
  ORG                                     \ set CP-T := NP-T
  R@ ,-T                                  \ CFA
  LAST-T DUP @ ,-T                        \ LFA 
  HERE-T SWAP !                           \ reset link point to a current name string
  COUNT DUP C,-T                          \ default LEX+LENGTH
  S,-T                                    \ fill string
  R> ORG                                  \ set assembly counter to code pointer
  ;
  
( Meta compiler create target image )
VARIABLE TARGET-LINK
0 TARGET-LINK !
   
: DO-TARGET  DOES> MAKE-CODE ;

: TARGET-CREATE ( -- )
  >IN @ HEADER >IN !
  TARGET DEFINITIONS
  CREATE
    HERE-T ,
    HERE TARGET-LINK @ , TARGET-LINK !
  DO-TARGET
  META DEFINITIONS ;
     
: RECREATE  ( -- )
  >IN @  TARGET-CREATE >IN ! ;
  
( Create target code words )
: INIT-ASSEMBLER  ( -- )
  [ ASSEMBLER ] CLEAR_ALL# [ META ]
  ASSEMBLER DEFINITIONS ;
  
: CODE  ( -- )
  TARGET-CREATE INIT-ASSEMBLER ;

: CALL,  ( taddr -- ) 
  HERE-T CELL- DUP ORG @-T THERE [ ASSEMBLER ]  # ,BL [ META ] ;          \ call with link to taddr

ASSEMBLER DEFINITIONS
: END-CODE IN-META ;
: C; END-CODE ;
META DEFINITIONS

comment:

( Late reference define word )
1F CONSTANT WIDTH 
: TOKENED ( a u a -- a )
  OVER WIDTH >
  ABORT" Token name is too long."
  DUP >R 2DUP C! CHAR+ SWAP MOVE R> ;
 
: TOKEN, ( a u -- )
   HERE OVER 1 + ALLOT ALIGN
   TOKENED DROP ;
 
: $TOKEN ( -- a )
   ((")) ;

: REFERENCE ( xt -<string>- )
   [ ' $TOKEN ] LITERAL COMPILE, BL WORD COUNT TOKEN, COMPILE, ;
 
: LATE ( a -- )
  FIND 
    IF EXECUTE
    ELSE ." =>" COUNT TYPE SPACE TRUE ABORT" is not yet defined."
    THEN
  ;
  
: [TARGET] ( | <string> -- )
  [ ' TARGET ] LITERAL COMPILE, 
  [ ' LATE ] LITERAL REFERENCE 
  [ ' META ] LITERAL COMPILE, ; IMMEDIATE

comment;

: FIND&EXECUTE  ( addr len wordlist -- ? )
        SEARCH-WORDLIST 0= ABORT" Target word not found"  EXECUTE ;

: DEFERED  ( wordlist -- )
        BL WORD COUNT POSTPONE SLITERAL
        POSTPONE LITERAL
        POSTPONE FIND&EXECUTE ;

: [TARGET]  ( -- )  TARGET-WORDLIST    DEFERED ; IMMEDIATE
 
( Find the next word in a single wordlist only )
: DEFINED-IN  ( -- xt )
        ' ( BL WORD COUNT ROT SEARCH-WORDLIST  0= ?MISSING ) ;

: 'T   ( -- xt )   ONLY ALSO TARGET DEFINED-IN ONLY FORTH ALSO META ALSO ;
: 'F   ( -- xt )   ONLY ALSO FORWARD DEFINED-IN ONLY FORTH ALSO META ALSO ;

: [FORWARD]   ( -- )    'F COMPILE, ;   IMMEDIATE

( Define transition words, which behave like forth immediate words )

: T:   TRANSITION DEFINITIONS  META  :  ;
: T;   [COMPILE] ;  META DEFINITIONS ; IMMEDIATE

: [TRANSITION]  ONLY ALSO TRANSITION DEFINED-IN COMPILE, ONLY FORTH ALSO META ALSO ; IMMEDIATE

T: (   [COMPILE] (   T;
T: \   [COMPILE] \   T;

: STRING,-T  [CHAR] " PARSE  DUP C,-T  S,-T ALIGN-T  ;

FORWARD: <(.")>

T: ."   [FORWARD]  <(.")>   STRING,-T   T;

\ FORWARD: <(S")>
\ T: S"    [FORWARD] <(S")>   STRING,-T   T;

FORWARD: <(ABORT")>
T: ABORT"   [FORWARD] <(ABORT")>    STRING,-T   T;

( Define target vocabularies uh, wordlists )

VARIABLE VOC-LINK-T
FORWARD: <VOCABULARY>

: VOCABULARY   ( -- )
        TARGET-CREATE
        [TARGET] DOLIST CALL, 
        [FORWARD] <VOCABULARY>
        0 ,-T
        HERE-T  VOC-LINK-T @ ,-T   VOC-LINK-T ! 
        ;

$80       CONSTANT =IMMEDIATE
$40       CONSTANT =COMPILE-ONLY
$7F7F7F1F CONSTANT =MASK


: IMMEDIATE   ( -- )
        LAST-T @  DUP C@-T =IMMEDIATE OR  ( Precedence Bit )  SWAP C!-T ;
  
: COMPILE-ONLY ( -- )
        LAST-T @  DUP C@-T =COMPILE-ONLY OR  ( compiler-only Bit )  SWAP C!-T ;

VARIABLE STATE-T

T: [COMPILE]   'T EXECUTE    T;

: >BODY-T  4 + ;

\ FORWARD: <(IS)>
\ T: IS      [FORWARD] <(IS)>    T;
\ :  IS    'T >BODY @ >BODY-T  2DUP !-T  8 + !-T ;
\  ( patches both current and default value of defered word )

( Meta Compiler Resolve Forward References )

0 VALUE #UNRESOLVED

: .UNRESOLVED   ( -- )
        0 TO #UNRESOLVED
        FORWARD-LINK
        BEGIN   @ DUP
        WHILE   DUP 2 CELLS - RESOLVED? 0=
                IF      DUP 2 CELLS - BODY> .NAME  ( *SYSDEP* )
                        1 +TO #UNRESOLVED
                THEN
                START/STOP
        REPEAT  DROP
        #UNRESOLVED
        IF      CR ." !!!!!! There were: " #UNRESOLVED . ." words Unresolved !!!!!!"
                3 0 DO BEEP 300 MS LOOP
        ELSE    CR ." *** No words Unresolved ***"
        THEN    ;

: FIND-UNRESOLVED   ( -- cfa f )
        'F    DUP  >BODY RESOLVED?     ;

: RESOLVE   ( taddr cfa -- )
        >BODY   2DUP TRUE OVER CELL+ !   @
        BEGIN   DUP
        WHILE   2DUP @-T   -ROT SWAP !-T
        REPEAT  2DROP  !   ;

: RESOLVES   ( taddr -- )
        FIND-UNRESOLVED
        IF      .NAME ." Already Resolved"   DROP  ( *SYSDEP* )
        ELSE    RESOLVE
        THEN   ;

( Meta compiler Branching & Looping )

T: IF      [TARGET] ?BRANCH  ?>MARK   T;

T: THEN                      ?>RESOLVE    T;
T: ELSE    [TARGET] BRANCH   ?>MARK   2SWAP ?>RESOLVE   T;

T: BEGIN                     ?<MARK   T;
T: AGAIN   [TARGET] BRANCH   ?<RESOLVE   T;
T: UNTIL   [TARGET] ?BRANCH  ?<RESOLVE   T;
T: WHILE   [TARGET] ?BRANCH  ?>MARK  2SWAP  T;
T: REPEAT  [TARGET] BRANCH   ?<RESOLVE  ?>RESOLVE   T;

T: FOR     [TARGET] >R       ?<MARK   T;
T: NEXT    [TARGET] _next    ?<RESOLVE T;
T: AFT     [TARGET] BRANCH   2DROP ?>MARK  ?<MARK 2SWAP T;      

T: ?DO     [TARGET] (?DO)    ?>MARK   T;
T: DO      [TARGET] (DO)     ?>MARK   T;
T: LOOP    [TARGET] (LOOP)   2DUP CELL+   ?<RESOLVE   ?>RESOLVE   T;
T: +LOOP   [TARGET] (+LOOP)  2DUP CELL+   ?<RESOLVE   ?>RESOLVE   T;

( Meta compiler literals )

T: LITERAL   ( n -- )   [TARGET] DOLIT  ,-T T;
T: [CHAR]    ( -- )     CHAR        [TRANSITION] LITERAL   T;
T: [']       ( -- )     'T >BODY @  [TRANSITION] LITERAL   T;

( Meta compiler defining words )

: USER  ( n -- )        
        RECREATE  [TARGET] DOLIST CALL, [TARGET] DOUSER 
        DUP ,-T   CONSTANT   ;

: CREATE  ( -- )
        RECREATE  [TARGET] DOLIST CALL, [TARGET] DOVAR 
        HERE-T CONSTANT  ;

: VARIABLE  ( -- )
        CREATE   0 ,-T   ;

: CONSTANT   ( n -- )
        RECREATE  [TARGET] DOLIST CALL, [TARGET] DOCON 
        DUP ,-T   CONSTANT   ;

FORTH VARIABLE DEFER-LIST-T META

: DEFER   ( -- )
        TARGET-CREATE   [TARGET] DODEFER 
        0 ,-T
        HERE-T  DEFER-LIST-T @ ,-T  DEFER-LIST-T !
        0 ,-T  ;

\ FORWARD: <(;CODE)>

\ T: ;CODE   ( -- addr )
\        [FORWARD] <(;CODE)>   HERE-T
\        STATE-T OFF   IN-META
\        INIT-ASSEMBLER T;

\ T: DOES>     ( -- addr )
\        [FORWARD] <(;CODE)>   HERE-T
\        [TARGET] DODOES CALL,   T;

( Identify numbers single numbers only )

: NUMBER?  ( addr len -- n f )
        OVER C@ [CHAR] - =              \ leading minus sign?
        DUP >R IF  1 /STRING  THEN
        0 0 2SWAP >NUMBER 0= NIP NIP  ( -- u f )
        R> IF SWAP NEGATE SWAP THEN ;

( Meta Compiler Compiling Loop. )

FORTH VARIABLE T-IN META
: TOKEN  ( -- addr )
        BEGIN   >IN @ T-IN !
                BL WORD  DUP C@ 0=
        WHILE   DROP REFILL  0= ABORT" end of file in definition"
        REPEAT  ?UPPERCASE ;

: ]   ( -- )
        STATE-T ON  IN-TRANSITION 
        BEGIN   IN-TRANSITION
                TOKEN FIND
                IF      EXECUTE
                ELSE    COUNT NUMBER?
                        IF      [TRANSITION] LITERAL 
                        ELSE    ." Test Point" CR
                                DROP T-IN @ >IN !
                                UNDEFINED ( create forward reference )
                        THEN
                THEN
                STATE-T @ 0=
        UNTIL   ;

T: [   IN-META   STATE-T OFF   T;
T: ;   [TARGET] EXIT [TRANSITION] [   T;

IN-ASSEMBLER
: $NEXT ( -- )
 \ -------- ITC Version1 ---------
 \ WP, IP,            ,MOV                \ get next CFA
 \ IP, IP, 4 #        ,ADD                \ point to new CFA
 \ WP                 ,BX                 \ jump to next CFA
 \ -------- ITC Version2 ---------
  [] PC, IP, 4 #      ,LDR                \ direct jump
  ;  
IN-META

( Interpretive words for Meta )
: !            !-T ; 
: '            'T >BODY @   ;
: ,           ,-T ;
: W,         W,-T ;
: C,         C,-T ;
: HERE     HERE-T ;
: ALLOT   ALLOT-T ;
: ,"    STRING,-T ;
: >BODY   >BODY-T ;

: :   TARGET-CREATE  [TARGET] DOLIST CALL, ] ;

( Include ARM7 eforth kernel )
FLOAD ARM7KERL.F

( Include ARM7 eforth system )
FLOAD ARM7EF.F

( Include ARM7 eforth extension )
FLOAD ARM7EXT.F

( Resolve metacompiler forward references )
' ."|           RESOLVES <(.")>
' _abort"       RESOLVES <(ABORT")>
' doVOC         RESOLVES <VOCABULARY> 
' INTO-LOCAL    RESOLVES INTO-LOCAL

( Initialize User Variables )

=SPP         SP0         ROM_USER + !  \ (SP0)      Pointer to bottom of the data stack.
=RPP         RP0         ROM_USER + !  \ (RP0)      Pointer to bottom of the return stack.
' ?RX        '?KEY       ROM_USER + !  \ ('?KEY)    Execution vector of ?KEY.
' TX!        'EMIT       ROM_USER + !  \ ('EMIT)    Execution vector of EMIT.
' accept     'EXPECT     ROM_USER + !  \ ('EXPECT)  Execution vector of EXPECT.
' kTAP       'TAP        ROM_USER + !  \ ('TAP)     Execution vector of TAP.
' TX!        'ECHO       ROM_USER + !  \ ('ECHO)    Execution vector of ECHO.
' .OK        'PROMPT     ROM_USER + !  \ ('PROMPT)  Execution vector of PROMPT.
=BASEE       BASE        ROM_USER + !  \ (BASE)     Storage of the radix base for numeric I/O.
                                       \ (tmp)      A temporary storage location used in parse and find.
                                       \ (SPAN)     Hold character count received by EXPECT.
                                       \ (>IN)      Hold the character pointer while parsing input stream.
                                       \ (#TIB)     Hold the current count. 
=TIB         #TIB CELL+  ROM_USER + !  \            Pointer to TIB 
                                       \ (CSP)      Hold the stack pointer for error checking.
' $INTERPRET 'EVAL       ROM_USER + !  \ ('EVAL)    Execution vector of EVAL.
' NUMBER?    'NUMBER     ROM_USER + !  \ ('NUMBER)  Execution vector of NUMBER?.
                                       \ (HLD)      Hold a pointer in building a numeric output string.
                                       \ (HANDLER)  Hold the return stack pointer for error handling.
                                       \ (CONTEXTA) Area to specify vocabulary search order.
                                       \            Vocabulary stack 
                                       \ (CURRENT)  Point to the vocabulary to be extended.
                                       \            vocabulary link pointer
CP-T @       CP          ROM_USER + !  \ (CP)       Point to the top of the code dictionary.
NP-T @       NP          ROM_USER + !  \ (NP)       Point to the bottom of the name dictionary.
LAST-T @     LAST        ROM_USER + !  \ (LAST)     Point to the last name in the name dictionary.

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
META

CR .( Unresolved references: ) CR   .UNRESOLVED
5 pause-seconds
