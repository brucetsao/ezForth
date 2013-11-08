\ Copyright (c) 2001 by Blueputer Technology Inc.
\ All rights reserved 

fload meta/Memory_Map.f
fload meta/Metacompiling_Initialization.f
fload meta/Vocanulary_Operations.f
fload meta/Meta_Compiling.f
fload meta/Header/ELF.f
fload meta/Table/ASCII_PATTERN_TABLE.f
fload meta/Output/Output.f
fload meta/Memory_Access.f
( Including Assembler )
chdir asm
 fload main_asm.f
chdir ..

fload meta/Including_Assembler.f
fload meta/branching_constructs.f
fload meta/code_definition_header.f
fload meta/create_target_image.f

\ : CALL,  ( taddr -- ) 
\  HERE-T CELL- DUP ORG @-T THERE [ ASSEMBLER ]  # ,BL [ META ] ;
fload meta/Create_target_code_words.f

fload meta/target_vocabularies.f
fload meta/compiler_Branching_Looping.f

( Include  eforth  )
\  FLOAD IO/debug.F
  FLOAD IO/IO.F


  FLOAD kernel/eForth/code/code_main.F
  fload  kernel/eForth/colon/system.f
 \ fload  kernel/eForth/colon/extension.f
  FLOAD  BIOS/IO_device1.F

fload meta/Resolve_metacompiler_forward_references.f
fload meta/Initialize_User_Variables.f
\ fload meta/Boot.f
META

CR .( Unresolved references: ) CR   .UNRESOLVED
5 pause-seconds
