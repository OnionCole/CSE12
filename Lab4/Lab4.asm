##########################################################################
# Created by:  Anderson, Cole
#              comander
#              2 March 2020
#
# Assignment:  Lab 4: Syntax Checke
#              CSE12, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: Read in a file name passed in as a program argument. If the name is invalid or too long, print an error. Otherwise,
#				iterate through the file taking note of opening and closing braces. If there is mismatch or a match
#				does not exist for a brace, print an error. If there is no error, print a success message. Only
#				a maximum of one error message.
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#
#
#
#######################		PSEUDOCODE:
#
# Program reads in a file name passed in as a program argument. If the name is invalid or too long, print an error. Otherwise,
#				iterate through the file taking note of opening and closing braces. If there is mismatch or a match
#				does not exist for a brace, print an error. If there is no error, print a success message. Only
#				a maximum of one error message.
# 
# get the program argument from memory
# loop (through the characters of the program argument):
# 	if this char renders the program name invalid:
#		print an error
#		do not pass GO do not collect $200 or open the file
#	number of chars found in the program argument += 1
# if (number of chars found in the program argument > long enough):
#	print an error
#	do not pass GO do not collect $200 or open the file
#
# open the file
#
# overall index = 0
# loop (through necessary buffers):
#	number of chars read in = read in a buffer worth of chars
#	this buffer index = 0
#	loop (through buffer worth of chars):
#		if (char is opener):
#			push char to stack
#			push overall index to stack
#		elif (char is closer):
#			pop from stack
#			if (mismatch):
#				print error message
#				go directly to jail
#		overall index += 1
#		this buffer index += 1
# 		if (this buffer index == number of chars read in)
#			advance token to Boardwalk; done with the boring stuffs
# if (stuff still on stack):
#	print error message
#	there is a hotel on the boardwalk go to debtor's prison
#
# collect $200, print success message
#
# if (the file was opened):
#	close the file
#
# syscall 10 to exit
#
#
#
#######################		REGISTERS:
# $t0: program input index iterator
# $t1: file character index iterator
# $t2: file character index in buffer iterator
# $t3: buffer string
# $t4: buffer character address
# $t5: character loaded from buffer
# $t6: number of characters loaded from buffer
# $t7: index of character on stack, popped from the stack
# $t8: character on stack, popped from the stack
# $t9: number of counted pairs of braces
# $s0: buffer size
# $s1: file descriptor
# $s2: initial $sp value
# $s3: initial program argument address value
# $s4: program argument character address
# $s5: character loaded from program argument

.data
	message:          .asciiz "You entered the file:\n"
	success_messageA: .asciiz "SUCCESS: There are "
	success_messageB: .asciiz " pairs of braces."
	em_pa:            .asciiz "ERROR: Invalid program argument."
	em_sos:           .asciiz "ERROR - Brace(s) still on stack: "
	em_brace:         .asciiz "ERROR - There is a brace mismatch: "
	em_a_i:           .asciiz " at index "
	newline:          .asciiz "\n"
	space:            .asciiz " "
	buffer:           .space  128
.text
	
	# SAVE REGISTER VALUES
	li   $s0, 128
	move $s2, $sp  # save the initial stack pointer value
	
	
	# GET PROGRAM FILE ARGUMENT
	lw $s3, 0($a1)  # store address 2A
	
	
	# PRINT PROGRAM FILE NAME
	
	# get and print program argument
	li      $v0, 4
	la      $a0, message
	syscall
	move    $a0, $s3
	syscall
	la      $a0, newline
	syscall
	syscall
	
	# CHECK IF GIVEN PROGRAM INPUT IS ACCEPTABLE
	li $t0, 0  # iterator
	input_chars_loop: NOP
		
		# get pos
		add $s4, $s3, $t0
		
		# load a char out of the buffer
		lb $s5, 0($s4)
		
		# break the loop if the char is a null
		beq $s5, 0, input_chars_done
		
		# do not check if char is not a letter if it is not the first char
		bne $t0, $zero, is_good_char
		
		# check if char is not a letter since this is the first char
		blt $s5,       65,  is_bad_arg    # if lower than 65, cannot be letter
		ble $s5,       90,  is_good_char  # if lower than equal to 90, is letter
		blt $s5,       97,  is_bad_arg    # if lower than 97, cannot be letter
		ble $s5,       122, is_good_char  # if lower than equal to 122, is letter
		j   is_bad_arg                    # if yet greater, cannot be letter
		
		is_good_char: NOP
		
		# increment iterator for next iteration
		addi $t0, $t0, 1
		
		# continue loop
		j input_chars_loop
		
		# NOP
		NOP
	input_chars_done: NOP	
	
	# check if more than 20 characters entered
	ble $t0, 20, not_bad_arg
	
	is_bad_arg: NOP  # the file name entered is not admissible
		
		#PRINT error message
		li      $v0, 4
		la      $a0, em_pa
		li      $a1, 0
		li      $a2, 0
		syscall
		
		# end the program
		j exit
		
		# NOP
		NOP
	not_bad_arg: NOP  # the file name entered is admissible
	
	# READ THROUGH FILE
	
	# open file
	li      $v0, 13
	move    $a0, $s3
	li      $a1, 0
	li      $a2, 0
	syscall
	move    $s1, $v0  # save the file descriptor
	
	# iterate through contents of file
	li $t1, 0  # the index of the current character in the file
	li $t9, 0  # the number of pairs of braces, in the case of success
	read_loop: NOP
	
		# read file
		li     $v0, 14
		move   $a0, $s1
		la     $a1, buffer
		move   $a2, $s0
		syscall
		
		# loop set up
		li   $t2, 0      # the iterator
		la   $t3, buffer
		move $t6, $v0    # this is the number of bytes that were loaded 
		
		buffer_loop: NOP
			
			# get pos
			add $t4, $t3, $t2
			
			# load a char out of the buffer
			lb $t5, 0($t4)
			
			# REM
			# below would print the char
			#li $v0, 11
			#move $a0, $t5
			#syscall
			
			
			# HERE WE DO THE STACK WORK AS WE FINALLY HAVE A CHAR IN THE FILE AVAILABLE
			
			
			# branch if $t5 is (, [, {
			beq $t5, 40,  is_opener  # (
			beq $t5, 91,  is_opener  # [
			beq $t5, 123, is_opener  # {
			
			# branch if $t5 is ), ], }
			beq $t5, 41,  is_closer  # )
			beq $t5, 93,  is_closer  # ]
			beq $t5, 125, is_closer  # }
			
			# skip all this if $t5 is not a bracket
			j bracket_done
			
			is_opener: NOP
				# $t5 is (, [, or {
				
				# push the opener to the stack
				addi $sp, $sp,  -4
				sw   $t5, ($sp)
				
				# push the index to the stack
				addi $sp, $sp,  -4
				sw   $t1, ($sp)
			
				# jump past is_closer
				j bracket_done
				
				# NOP
				NOP
			is_closer: NOP
				# $t5 is ), ], }
				
				# check if this is really just an extra close and there is nothing to try matching with (like ']' with nothing on the stack)
				bne $s2, $sp, is_stack_val
				
				# this is an extra closer, so print error and end program
				
				#PRINT error message
				
				# first part
				li      $v0, 4
				la      $a0, em_brace
				li      $a1, 0
				li      $a2, 0
				syscall
				
				# print $t5, the closer which has no value in the stack
				li      $v0, 11
				move    $a0, $t5
				syscall
				
				# ' at index '
				li      $v0, 4
				la      $a0, em_a_i
				syscall
				
				# print the index
				li      $v0, 1
				move    $a0, $t1
				syscall
	
	
				# close the file and end the program
				j all_finished
				
				is_stack_val: NOP
				
				# pop index from the stack
				lw   $t7, ($sp)
				addi $sp, $sp,  4
				
				# pop opener from the stack
				lw   $t8, ($sp)
				addi $sp, $sp,  4
				
				
				#LOGIC check if the popped value pairs with $t5
				
				bne $t5,         41, not_b_1      # )
				beq $t8,         40, is_matching  # we popped the matching opener
				j   not_matching
				
				not_b_1: NOP  # $t5 is not }
				
				bne $t5,         93, not_b_2      # ]
				beq $t8,         91, is_matching  # we popped the matching opener
				j   not_matching
				
				not_b_2: NOP
				
				                                   # no bne here as $t5 must be '}'
				beq $t8,         123, is_matching  # we popped the matching opener
				j   not_matching
				
				
				not_matching: NOP
				
					# PRINT error message
					
					# first part
					li      $v0, 4
					la      $a0, em_brace
					li      $a1, 0
					li      $a2, 0
					syscall
					
					# print $t8, the opener pulled from the stack
					li      $v0, 11
					move    $a0, $t8
					syscall
					
					# ' at index '
					li      $v0, 4
					la      $a0, em_a_i
					syscall
					
					# print the index of the opener
					li      $v0, 1
					move    $a0, $t7
					syscall
					
					# space
					li      $v0, 4
					la      $a0, space
					syscall
					
					# print $t5, the closer which has the wrong opener
					li      $v0, 11
					move    $a0, $t5
					syscall
					
					# ' at index '
					li      $v0, 4
					la      $a0, em_a_i
					syscall
					
					# print the index of $t5, the closer which has the wrong opener
					li      $v0, 1
					move    $a0, $t1
					syscall
					
					
					# close the file and end the program
					j all_finished
				
				is_matching: NOP  # if the closer matched with the popped value
				
				# this pop was successful, increment the braces pair count
				addi $t9, $t9, 1
			
				# NOP
				NOP
			bracket_done: NOP
			
			
			# increment iterators for next iteration
			addi $t1, $t1, 1
			addi $t2, $t2, 1
			
			# exit iteration of this buffer if this was the last char
			beq $t2, $t6, buffer_done
		
			
			# continue loop
			j buffer_loop
			
			# NOP
			NOP
		buffer_done: NOP
		
		# if the number of chars pulled this time is not equal to the max, that was the last in the file
		bne $t6, $s0, read_done
		
		# continue loop
		j read_loop
		
		# NOP
		NOP
	read_done: NOP
	
	# check if there are still braces left on the stack by comparing the current stack pointer value to the initial
	beq $sp, $s2, success
	
	#PRINT error message 
	
	# print first part
	li      $v0, 4
	la      $a0, em_sos
	li      $a1, 0
	li      $a2, 0
	syscall
	
	# print the braces still on the stack
	stack_read_loop: NOP
	
		# move the stack past the index as we do not need it
		addi $sp, $sp,  4
			
		# pop opener from the stack
		lw   $a0, ($sp)
		addi $sp, $sp,  4
		
		# print the popped char
		li      $v0, 11
		syscall          # using $a0 as popped from stack right above
		
		
		# continue loop if the current stack pointer still does not match the initial
		bne $sp, $s2, stack_read_loop
	
		# NOP
		NOP
	
	# close the file and end the program
	j all_finished  # this was not a success, otherwise success would have been jumped to above
	
	success: NOP
		#PRINT success message
		
		# part A
		li      $v0, 4
		la      $a0, success_messageA
		li      $a1, 0
		li      $a2, 0
		syscall
		
		# print number of pairs of braces
		li      $v0, 1
		move    $a0, $t9
		syscall
		
		# part B
		li      $v0, 4
		la      $a0, success_messageB
		syscall
		
	all_finished: NOP
	
		# close file
		li      $v0, 16
		move    $a0, $s1
		li      $a1, 0
		li      $a2, 0
		syscall
	
	exit: NOP
	
		# print newline
		li      $v0, 4
		la      $a0, newline
		syscall
	
		# exit program
		li      $v0, 10
		li      $a0, 0
		syscall
	