      #include "Arm_eForth.h"
      ;MODULE  Forth
        PUBWEAK Forth_AND
        SECTION .ForthRom:CODE:NOROOT(2)
                THUMB
Forth_AND       
;CODE AND ;( w1 w2 -- w )    ;\ Bitwise AND.
;  LDR   WP, [SP], #4        ;\ WP = [SP], SP := SP+4
;  AND   TOS, TOS, WP        ;\ TOS := TOS and WP
;  NEXT
;END-CODE

;CODE AND ;( w1 w2 -- w )    ;\ Bitwise AND.
  LDR   WP, [SP], #4        ;\ WP = [SP], SP := SP+4
  AND   TOS, TOS, WP        ;\ TOS := TOS and WP    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
 LDR  IP,[IP]     
 STR  IP,[IP]     
 LDR  TOS,[IP],#4 
 LDR  PC,[IP],#4
 LDR  IP,[RP],#4  
 LDR  TOS,[RP]    
 LDR  TOS,[RP],#4 
 LDR  TOS,[SP]    
 LDR  TOS,[SP],#4 
 LDR  WP,[SP]     
 LDR  WP,[SP],#4  
 LDR  TOS,[SP,#4] 
 LDR  TOS,[TOS]   
 MOV  TOS,#0      
 MOV  WP,#0       
 LDRB TOS,[TOS]   
 STR  IP,[RP],#4  
 ADD  IP,IP,#4         
 MOV  IP,LP       
 MOV  TOS,RP      
 MOV  TOS,SP      
 EOR.W  TOS,TOS,WP
 STR  TOS,[RP],#4 
 STR  TOS,[RP,#4] 
 STR  TOS,[SP]    
 STR  TOS,[SP],#4 
 STR  TOS,[SP,#4] 
 MOV  RP,TOS      
 MOV  SP,TOS      
 MOV  WP,TOS      
 ADC  TOS,TOS,#0       
 ADD  WP,WP,TOS        
 ORR.W  TOS,TOS,WP
 STR  WP,[SP]     
 STR  WP,[TOS]    
 STRB WP,[TOS]    
 MOV  TOS,WP      
 ADD  TOS,WP,TOS,ASR#20
        
 BX   WP   
  NEXT
;END-CODE  
        END