; Name : Suyashi Singhal 
; Roll no: 2019478

[bits 16]                               ; initially in 16 bit mode
[org 0x7c00]							; sets the initial address to boot 

boot:
	cli 
	lgdt [global_descriptor]			;load the global descriptor table
	jmp protected_mode_switch           ; we jump to the function to switch to


protected_mode_switch: 
		mov		eax, cr0				;in order to switch to protected mode 
		or		eax, 0x1 				;lsb of cr0 is set to 1 
		mov		cr0, eax				;cr0 is a control register
		jmp		CODE:initialize			;we jump to the code section of gdt    


global_descriptor_main:                 ; this is the start of the global descriptor table 
										; used to calculate size of this table 
		dq 0x0

global_descriptor_null:					;null descriptor 
		dd 0x0 							; here dd-define double word
		dd 0x0

global_descriptor_code: 				; this is the code segment name 
		dw 0xFFFF						; limit = 0xffff (0 to 15 bits)
		dw 0x0 							; base level(0-15 bits)
		db 0x0							; base level(16-23 bits)
		db 10011010b					; Accessed - if this segment has been accessed or not
										; 1(present) 00(priveledge) 1(descriptor type) -> ;first four bits(1001b)
										; 1(code) 0(conforming) 1(readable) 0(accessed) -> ;last four bits(1010b)
		db 11001111b				
		db 0x0							; base level(14-31 bits)


global_descriptor_data:					; this is the data segment
		dw 0xFFFF						; limit = 0xffff (0 to 15 bits)
		dw 0x0 							; base level(0-15 bits)
		db 0x0							; base level(16-23 bits)
		db 10010010b					; 1(present) 00(priveledge) 1(descriptor type) ->
										; first four bits(1001b)
										; 0(code) 0(expand down ) 1(writable) 0(accessed) ;->last four bits(1010b)
		db 11001111b					
		db 0x0							; base level(14-31 bits)

global_descriptor_end:                  ;we have included this in order to calculate the
										;size of the global descriptor table which is
  										;global_descriptor_end - global_descriptor_end

global_descriptor: 
	dw global_descriptor_end - global_descriptor_main - 1  ; size of gdt 
	dd global_descriptor_main           ; this is the start address of gdt 
	
 
CODE equ global_descriptor_code - global_descriptor_main 
DATA equ global_descriptor_data - global_descriptor_main

[bits 32]
initialize:
		mov		ax, DATA
	    mov 	es, ax
	    mov 	ss, ax
	    mov 	fs, ax
	    mov 	gs, ax
	    mov 	ds, ax
	    mov		ebp, 0x900000 			
	    mov		sp, bp					;putting the stack pointer to the top of the free space
	    jmp 	print_values

print_values:
		mov 	esi, print_1			; put the address of print_1 in esi register
		mov		ah, 0x0e
		mov		ebx, 000b8000h + 1280	
		mov 	edx, cr0   				; value of CR0 register             	  
    	mov 	ecx, 0         			; counter 
    	

check:
	mov eax, 00000130h   			
    rol edx, 0x1           				; left rotate, sets the carry flag with the bit that 
    									; moved to left
    jc  add_1							; if carry is 1, we go to add_1

add_0:
    add eax, 0							; add 0 to eax since the bit is 0 
    mov [ebx], ax						; print 0
    jmp continue 						; jump to continue function 

add_1:
	add eax, 1							; add 1 to eax since the bit is 1
	mov [ebx] , ax						; print 1
	jmp continue						; jump to continue function 
	

continue: 
    add ebx, 2							; add 2 to ebx to update position of pointer
    add ecx, 1							; increment counter by  1
    cmp ecx, 32							; compare counter with 32
    jne check 							; if not equal jump to check, to loop through next bit

next_line:
	add 	ebx, 0 

hello:										; to print "Hello World!"

	lodsb									; loads the current byte from esi to al
	cmp 	al, 0							; compares al to 0, if al == 0 then it means the 
											; message has been printed 
	or 		eax, 0x0100
	je		stop							; when al becomes 0, the loop exits
	mov 	word [ebx], ax					
	add		ebx, 2
	jmp     hello 							

stop:										; stops the execution of program after everthing 
											; has been printed
	cli 									; clears interrupts 
    hlt										; halts execution 


print_1:  db "    Hello world!", 0 			; this is the message to be printed 
times 510 - ($-$$) db 0 					; since the file should be of 512 bytes, we fill 										     ; the output file with 510
dw 0xaa55									; we set the last two bytes with this number 
											; which makes the binary bootable
