\ Copyright (c) 2001 by Blueputer Technology Inc.
\ All rights reserved 



fload meta/Initialize.f
fload meta/Memory_Map.f
fload meta/Header/ELF.f
fload meta/Table/ASCII_PATTERN_TABLE.f

fload meta/Output/Output.f

( Including Assembler )
chdir asm   fload main_asm.f chdir ..
fload meta/Including_Assembler.f

fload meta/branching_constructs.f
fload meta/code_definition_header.f

fload meta/target_image.f
\ : CALL,  ( taddr -- ) 
\  HERE-T CELL- DUP ORG @-T THERE [ ASSEMBLER ]  # ,BL [ META ] ;
fload meta/target_code_words.f
fload meta/target_vocabularies.f


fload meta/compiler_Branching_Looping.f



( Include  eforth  )

\  FLOAD IO/debug.F           \ BIOS
  FLOAD IO/IO.F 

  FLOAD kernel/eForth/code/code_main.F
  fload  kernel/eForth/colon/system.f

   \ fload  kernel/eForth/colon/extension.f
  FLOAD  BIOS/IO_device1.F  \ IO
  
 fload meta/Boot.f

\ fload FileSystem/paths.f
META

CR .( Unresolved references: ) CR   .UNRESOLVED
5 pause-seconds

WRITE_AXF_FILE