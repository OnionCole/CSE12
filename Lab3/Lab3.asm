##########################################################################
# Created by:  Anderson, Cole
#              comander
#              13 February 2020
#
# Assignment:  Lab 3: ASCII-risks (Asterisks)
#              CSE12, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: Program print a triangle in console of height h as given by user input containing ascending numbers and stars
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#
#
#
#######################		PSEUDOCODE:
#
# Program takes a natural number from the user, rejecting any unnacceptable input with an error message and a repeated prompt.
# Given the input N, print a "triangle" in the console like so (if N == 3):
# 		1
# 	2	*	3
#4	*	5	*	6
# Then print another newline and exit.
#
# loop:
# 	Print the input prompt
#	Take the input
#	Break the loop if the input is a natural number
#	
#	Print the error message
#
# loop:
#
#	Print the line by,
#	Figuring the number of tabs to print as the number of lines yet to print after the current one
#	Printing that figure of tabs
#	Figuring the number of numbers and stars to print as the total number of lines in the triangle times 2, minus the number of lines yet to 
#			print after this line times 2, minus 1
#	
#	loop:
#		Using a register to store whether the next element ought be a number or a star, print ascending numbers and stars with tabs in 
#				between in an alternating fashion, beginning with a number, until the number of items for this line have been 
#				printed
#	
#	Print a newline
#	Break the loop if there are no lines left to print
#
# syscall 10 to exit
#
#
#
#######################		REGISTERS:
# $t0: The lines input
# $t1: The lines left to print
# $t2: Number of beginning tabs left to print on each line
# $t3: The next number to print
# $t4: Double the lines input
# $t5: Number of values left to print on each line
# $t6: 0 for printing a number next, 1 for printing a star next
# $t7: Stores if the number of beginning tabs left to print is less than 1, in which case the program needs to stop printing tabs

.data
	message:            .asciiz "Enter the height of the triangle (must be greater than 0): "
	bad_input_message:  .asciiz "Invalid entry!\n"
	tab:                .asciiz "\t"
	newline:            .asciiz "\n"
	star:               .asciiz "*"
.text
	
	# Get A Good Input
	
	input_loop: NOP
	
		# Print Message
		li      $v0, 4
		la      $a0, message
		syscall
		
		# Get Input
		li      $v0, 5
		syscall
		
		# Store Input In Temp Register
		move $t0, $v0
		
		# Break Loop If The Input Is Good
		slti $t1, $t0,   1
		beq  $t1, $zero, input_done # if its good
			
		# Print Error Message
		li $v0, 4
		la $a0, bad_input_message
		syscall
		
		# Go Back To Top Of Loop
		j input_loop
		
		NOP
	input_done: NOP
	# at this point, $t0 holds a positive integer
	
	# Print The Output
	add  $t4, $t0, $t0  # double the number of lines
	move $t1, $t0       # count of lines left to print
	li   $t3, 1         # this is the register for the number outputs
	output_loop: NOP
		
		# Decrement The Number Of Lines Left After This
		addi $t1, $t1, -1
		
		# Print Tabs
		
		# prepare to print tab
		li $v0, 4
		la $a0, tab
		
		# print the tabs
		move $t2, $t1  # this var is the number of tabs yet to print
		tabs_loop: NOP
			slti    $t7,      $t2,   1
			bne     $t7,      $zero, tabs_done  # quit loop if no tabs left
			syscall                             # print a tab
			addi    $t2,      $t2,   -1         # decrement the number of lines left after this
			j       tabs_loop                   # continue the loop
			
			NOP
		tabs_done: NOP
		NOP
		
		# Print Values
		
		# figure how many values to print
		sub  $t5, $t4, $t1
		sub  $t5, $t5, $t1
		addi $t5, $t5, -1
		
		# print the values
		li $t6, 0  # 0 to print number, 1 for star
		values_loop: NOP
			addi $t5, $t5, -1  # decrement the number of lines left after this
			
			# see if need to print int or star
			beq $t6,          $zero, ExecPrintInt
			j   ExecPrintStar

			# IF we are to print an int
			ExecPrintInt: NOP
			
				# print the int
				li      $v0, 1
				move    $a0, $t3
				syscall
				
				# increment the number output var
				addi $t3, $t3, 1
				
				# indicate a star is printed next
				li $t6, 1
				
				# jump past next
				j ExecPrintEnd
				
				NOP
			
			# ELIF we are to print a star
			ExecPrintStar: NOP
				
				# print the star
				li      $v0, 4
				la      $a0, star
				syscall
					
				# indicate a char is printed next
				li $t6, 0
				
				NOP
			ExecPrintEnd: NOP
			NOP
			
			# quit loop if no tabs left
			beq $t5, $zero, values_done
			
			# print tab
			li      $v0, 4
			la      $a0, tab
			syscall
			
			# continue the loop
			j values_loop
			
			NOP
		values_done: NOP
		NOP
		
		# Print Newline
		li      $v0, 4
		la      $a0, newline
		syscall
		
		# Quit Loop If No Lines Left
		beq $t1, $zero, output_done
		
		# Continue The Loop
		j output_loop
		
		NOP
	output_done: NOP
	NOP
	
	# Exit Program
	li      $v0, 10
	li      $a0, 0
	syscall
