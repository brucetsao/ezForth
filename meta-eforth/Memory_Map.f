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
8000 CONSTANT IMAGE_SIZE
CREATE IMAGE  IMAGE_SIZE ALLOT
IMAGE IMAGE_SIZE ERASE