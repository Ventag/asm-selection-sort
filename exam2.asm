
/*

          SELECTION SORT ALGORITHM

*/

.section .data
int_counter:
        .space 8                #8 bytes 64 bit
.section .text
.globl _start
_start:
	/** Load File **/
	mov 16(%rsp), %rdi 	#load cmdline args into rdi
	mov $2, %rax            #open file
        mov $0, %rsi
	mov $0, %rdx 		#read only args
        syscall

	/** Allocate Space for File in Memory **/
	push %rax		#push the file descriptor to the stack 
	call get_file_size 	#gets the size of the file (which is in rax)
	pop %r15		#pop the file descriptor from the stack and save it in r15
	push %rax 		#push the size of the file to the stack
	call alloc_mem		#allocate the size of the file in Memory
	mov %rax, %r14		#move file pointer to r14
	pop %r8			#pop the file size to r8

	/** Save File to Memory **/
	mov $0, %rax		#0 = read
	mov %r15, %rdi 		#r15 file descriptor
	mov %r14, %rsi 		#r14 pointer to the file memory buffer
	mov %r8, %rdx 		#r8 ascii file size
	syscall

	/** Get Count of Numbers **/
	push %r8 			#push size of file to the stack
	push %r14			#push pointer to memory to the stack
	call get_number_count           #number count saved to rax
	pop %r14			#put pointer back to r14
	pop %r8				#clear stack and put size of file into r8

	/** Allocate Memory for Number Buffer **/
	mov $8, %rdi
	mul %rdi 				#time rax with 8 and save in rax
	mov %rax, %r13 		#save result to r13
	push %r13			#push r13 onto the stack
	call alloc_mem 		#gives us some memory, and a pointed placed in rax
	mov %rax, %r12		#save pointer to r12
	pop %r13			#empty stack and save it back to r13

	########### Registers #############
	# R8  - Size of File              #
	# R12 - Pointer to Integer Buffer #
	# R13 - Size of Integer Buffer    #
	# R14 - Pointer to File Buffer    #
	# R15 - File descriptor		  #
	###################################

	/** Parse Ascii into Integers **/
	push %r12 			#3. argument, where to save the Integers
	push %r8 			#2. argument, size of ascii input
	push %r14  			#1. argument, location of the ascii buffer
	call parse_number_buffer        #save the integers to the assigned buffer
	pop %r14
	pop %r8
	pop %r12 			#empy stack, and put everything back


	/** Sorting **/
	#start by finding the highest number
	mov $0, %r9 		#this is where we compare numbers
	mov $8, %r10		#counter, 16 as an offset
	mov %r12, %rcx 		#save start of pointer
	mov $0, %rdi		#found higest numbers, keeps track of when/where
	jmp highest_number

highest_number:
	cmp %rdi, %r13
	je extract_list
        
	cmp %r9, (%r12) 	#check to see if r9 is less than r12 current number
	jge set_highest_number #if so we jump to setting the highest number
	jmp move_to_next_segment #we move to the next 64 bit

set_highest_number:
	mov (%r12), %r9 	#here we set the number we think is the higest to r9
	mov %r12, %rax		#move the current memory pointer to rax
	jmp move_to_next_segment

move_to_next_segment:
	cmp %r10, %r13 		#compare the current number with the size of the buffer so we know when we have been through all the numbers 
	je found_highest        #if so, we found the highest number and jump here

	add $8, %r12            #current number is still smaller than size of buffer, increment integer buffer
	add $8, %r10
	jmp highest_number      #continue algorithm

found_highest:
	add $8, %rdi 		#add 16 to the final counter, to check if we are all done.

	push %r9		#put the highest number to the top of the stack

	movq $-1, (%rax)

	mov $8, %r10 		#start counter over
	mov %rcx, %r12 		#start the integer pointer over
	mov $0, %r9             #reset r9
	jmp highest_number

extract_list:
	mov $0, %r15 		#start a new counter
	jmp loop_through_stack

loop_through_stack:
	cmp %r15, %rdi    	#check to see if we are all the way through the stack
	je exit			#if so, exit as we are done
	add $8, %r15           #increment counter as we're not through the stack yet
	call print_number       #print to stdout
	pop %r8                 #restore r8
	jmp loop_through_stack  #recursively call ourselves untill stack is through

	/** Exit Program **/
exit:
        push %rax               # preserve value of rax
        mov int_counter, %rax   # move current value of int_counter to rax
        push %rax               # push rax to stack
        call print_number       # calls print_numer on stack
        pop %rax                # restore rax
        pop %rax                # restore rax to initial value before moving int_counter to rax

	mov $60, %rax            # rax: int syscall number
	mov $0, %rdi             # rdi: int error code
	syscall
