\ asm arg

create 	a1$	512 allot	
create 	a2$	512 allot	
create 	a3$	512 allot	  
create 	a4$	512 allot

: arg	( --- kiss )
		BL word count a1$ place
		\ ascii ; word count a1$ place    
		\ 0x0a word count a1$ place
        
		a1$ count ascii ; scan temp$ place 		\ ���o���� 
		a1$ c@ temp$ c@ - a1$ c!	  		\ ���o�Ѽ�	
		a1$ count ascii , scan a2$ place	\ ���� �Ĥ@��G�T�Ѽ�		
		a1$ c@ a2$ c@ - a1$ c!		\ ���o �Ĥ@�Ѽ�
		a1$ dup count BL skip rot place			\ 	�Ĥ@�Ѽƥh�Y
		a1$ dup count  -trailing rot place		\ 	�Ĥ@�Ѽƥh��			
		a2$ dup count ascii , skip rot place		\ 	�ĤG�T�Ѽƥh�Y
		a2$ count ascii , scan a3$ place	\ ���� �ĤG��T�Ѽ�
		a2$ c@ a3$ c@ - a2$ c!		\ ���o �ĤG�Ѽ�
		a2$ dup count  -trailing rot place		\ 	�ĤG�Ѽƥh��			
		a3$ dup count ascii , skip rot place		\	�ĤT�Ѽƥh�Y		
		a3$ dup count  -trailing rot place		\ 	�ĤT�Ѽƥh��
    ;    