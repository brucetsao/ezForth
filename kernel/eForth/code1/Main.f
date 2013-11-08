	AREA _plasma, CODE, READONLY
		GET	Define\Define.s		;
		GET	Boot\Boot.s 		
;		GET	ForthBase\GbaForth.s	; GBA-Forth OS Defing
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		�Ŧ��t�� GBA-Forth V1.2004.12.15 �i�P�n��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	�Ȧs��
;			R0~3	: �������_�v�T,��FORTH�]���O�@
;       	R4~8    : USER �i�ϥ�,���� PushReg & PopReg �ӫO�@
;			R8		:
;			R9		:
;			r10		:
;			R11		: 
;			R12		: Forth �����|����
;       	R13(SP) : ARM7 SP ��^���|����
;       	R14(LR) : ARM7 �Ƶ{����^,Link Call ��,Forth ��IP
;       	R15(PC) : ARM7 �{�ǭp��
;       	CPSR	: ARM7(System&USER Mode)���A 		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NEXT
        MACRO
 NEXT   
        MOV    pc, lr
        MEND    
;        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
; NEST
        MACRO
 NEST        
	STMDB	SP!,{LR}	; PUSH LR TO [RP]
	MEND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UNNEST
        MACRO
 UNNEST        
	LDMIA	SP!,{LR}	; POP [RP] TO LR
	NEXT
	MEND
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EXECUTE
	MACRO
 EXECUTE
        LDMIA	SP!,{PC}         ; jmp [w] PC->LR           
	NEXT
	MEND	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LIT	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �sĶ
        MACRO	
 LIT    $p1    
        BL     LIT_CODE
        DCD	$p1
        MEND 
; �Y��
        
; ����           
LIT_CODE
    LDR     R0,[LR]
	stmdb	r12!,{R0}				
	add		LR,LR,#4	
	NEXT		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DROP
       MACRO
 DROP      
       BL       DROP_CODE
       MEND
DROP_CODE
	
	ldmia	r12!,{R0}	 
	NEXT		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
; �_���w�q��    		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MACRO
 Cold        
        BL      Cold_CODE 
        MEND

Cold_CODE
         NEST
         LIT   1234
         DROP
	UNNEST		
				
Start
	mov 	r0, #Cpu_Mode_IRQ:OR:0x80:OR:0x40	; Disable interrupts
	msr 	CPSR_c, r0		; Enable IRQ mode
	ldr 	r13,=0x03007FA0	; �]�wIRQ �� ���|��}�� 0x03007FA0
	
;	ldr	r0,=REG_INTERRUPT	 ; �]�w���_�A�ȵ{�� �_�l��}
;	ldr	r1,=ServiceInterrupt
;	str	r1,[r0]
					;
    MOV     R0, #0x1F               ;
    MSR     CPSR_c, R0              ;

    LDR     SP,=0x03007000          ; �]�w���| SP �� 0x03007000      
				       				;
    LDR     r10,=0x03006000         ;�]�w�j�| r10 ��}�� 0x03006000       
        

        
        MOV     r12, #0		 	; ���� cold  
        MOV     r11, #0                                                            
        LDR     r8,=Cold_CODE   			; PUSH Cold_CFA
        STMDB   sp!,{r8}                        
        EXECUTE

		LTORG
			      		
		END