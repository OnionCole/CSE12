##########################################################################
# Created by:  Anderson, Cole
#              comander
#              13 March 2020
#
# Assignment:  Lab 5: Functions and Graphics
#              CSE12, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: Implement Raster graphics facilities through subroutines.
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################


#Winter20 Lab5 Template File

# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.
.macro push(%reg)
addi $sp, $sp,  -4
sw   %reg, ($sp)

.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)
lw   %reg, ($sp)
addi $sp, $sp,  4

.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)
rol %x, %input, 16    # %x is not 0x00YY00XX
rem %x, %x,     256
rem %y, %input,     256

.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)
move %output, %x
rol  %output, %output, 16
add  %output, %output, %y

.end_macro 


.data
originAddress: .word 0xFFFF0000

.text
j done
    
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# clear_bitmap:
#  Given a clor in $a0, sets all pixels in the display to
#  that color.	
#-----------------------------------------------------
# $a0 =  color of pixel
#*****************************************************
clear_bitmap: nop

#	# PSEUDO:
#	push registers
#	save args
#	x_iterator, y_iterator = 0,0
#	while (True):
#		draw pixel corresponding to x and y iterators
#		x_iterator+=1
#		if (x_iterator < 128):
#			continue
#		x_iterator=0
#		y_iterator+=1
#		if (y_iterator < 128):
#			continue
#		break
#	pop registers
	
	

	# PUSH
	
	# save registers
	push ($s0)
	push ($s1)
	push ($s2)
	push ($s3)
	push ($s4)
	push ($s5)
	push ($s6)
	push ($s7)
	
	# arg registers
	push ($a0)
	push ($a1)
	push ($a2)
	push ($a3)
	
	# return registers
	push ($v0)
	push ($v1)
	
	# ra
	push ($ra)


	# STORE ARGS
	move $s0, $a0  # color of pixel
	

	# --MAIN--
	
	# wash bitmap
	li $s1, 0  # x iterator
	li $s2, 0  # y iterator
	clear_bitmap_loop: nop
		
		# draw the pixel
		formatCoordinates ($a0,       $s1, $s2)  # set the coordinat
		move               $a1,       $s0        # set the color
		jal                draw_pixel            # draw the pixel
		
		# increment x iterator
		addi $s1, $s1, 1
		
		# continue loop
		blt $s1, 128, clear_bitmap_loop
		
		# reset x iterator
		li $s1, 0
		
		# increment y iterator
		addi $s2, $s2, 1
		
		# continue loop
		blt $s2, 128, clear_bitmap_loop
		
		# nop
		nop
	
	# POP
	
	# ra
	pop ($ra)
	
	# return registers (no return)
	pop ($v1)
	pop ($v0)
	
	# arg registers
	pop ($a3)
	pop ($a2)
	pop ($a1)
	pop ($a0)
	
	# save registers
	pop ($s7)
	pop ($s6)
	pop ($s5)
	pop ($s4)
	pop ($s3)
	pop ($s2)
	pop ($s1)
	pop ($s0)
	
	
	# JUMP RETURN
	jr $ra
	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1
#  [(row * row_size) + column] to locate the correct pixel to color
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# $a1 = color of pixel
#*****************************************************
draw_pixel: nop

	# PSEUDO
#	store pixel color to memory address figured as base plus 4 * (128 * y value + x value)



	# SUBR NOTES: LEAF, USES NO $s REGISTERS


	# --MAIN--
	
	# get coords
	getCoordinates ($a0, $t0, $t1) # store x coord to $t0, y to $t1
	
	# put offset into $t1
	mul $t1, $t1, 128
	add $t1, $t1, $t0
	mul $t1, $t1, 4
	add $t1, $t1, 0xFFFF0000
	
	# store pixel
	sw $a1, ($t1)
	
	
	# JUMP RETURN
	jr $ra

#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# returns pixel color in $v0	
#*****************************************************
get_pixel: nop

	# PSEUDO
#	get pixel color from memory address figured as base plus 4 * (128 * y value + x value)

	

	# SUBR NOTES: LEAF, USES NO $s REGISTERS


	# --MAIN--
	
	# get coords
	getCoordinates ($a0, $t0, $t1) # store x coord to $t0, y to $t1
	
	# put offset into $t1
	mul $t1, $t1, 128
	add $t1, $t1, $t0
	mul $t1, $t1, 4
	add $t1, $t1, 0xFFFF0000
	
	# load pixel
	lw $v0, ($t1)
	
	
	# JUMP RETURN
	jr $ra
	
#***********************************************
# draw_line:
#  Given two coordinates, draws a line between them 
#  using Bresenham's incremental error line algorithm	
#-----------------------------------------------------
# 	Bresenham's line algorithm (incremental error)
# plotLine(int x0, int y0, int x1, int y1)
#    dx =  abs(x1-x0);
#    sx = x0<x1 ? 1 : -1;
#    dy = -abs(y1-y0);
#    sy = y0<y1 ? 1 : -1;
#    err = dx+dy;  /* error value e_xy */
#    while (true)   /* loop */
#        plot(x0, y0);
#        if (x0==x1 && y0==y1) break;
#        e2 = 2*err;
#        if (e2 >= dy) 
#           err += dy; /* e_xy+e_x > 0 */
#           x0 += sx;
#        end if
#        if (e2 <= dx) /* e_xy+e_y < 0 */
#           err += dx;
#           y0 += sy;
#        end if
#   end while
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
draw_line: nop

#	# PSEUDO
#	push registers
#	save args
#	figure dx
#	figure sx
#	figure dy
#	figure sy
#	figure err
#	while (True):
#		plot first point
#		if (first point == second point):
#			break
#		te = 2*err
#		using te augment, augment err, first point
#	pop registers



	# PUSH
	
	# save registers
	push ($s0)
	push ($s1)
	push ($s2)
	push ($s3)
	push ($s4)
	push ($s5)
	push ($s6)
	push ($s7)
	
	# arg registers
	push ($a0)
	push ($a1)
	push ($a2)
	push ($a3)
	
	# return registers
	push ($v0)
	push ($v1)
	
	# ra
	push ($ra)

	
	# STORE ARGS
	move $s0, $a0  # first coord
	move $s1, $a1  # second coord
	move $s2, $a2  # color
	

	# --MAIN--
	
	# SETUP
	
	# pull out x and y values for first and second coords
	getCoordinates($s0, $t0, $t1)
	getCoordinates($s1, $t2, $t3)
	
	# dx
	sub $s3, $t2, $t0
	abs $s3, $s3
	
	# sx
	blt $t0, $t2, draw_line_sx_1_st
	li  $s4, -1
	j draw_line_sx_2_st
	draw_line_sx_1_st: nop
		li  $s4, 1
		nop
	draw_line_sx_2_st: nop
	
	# dy
	sub $s5, $t3, $t1
	abs $s5, $s5
	mul $s5, $s5, -1 
	
	# sy
	blt $t1, $t3, draw_line_sy_1_st
	li  $s6, -1
	j draw_line_sy_2_st
	draw_line_sy_1_st: nop
		li  $s6, 1
		nop
	draw_line_sy_2_st: nop
	
	# err
	add $s7, $s3, $s5
	
	
	# MAIN ALG
	draw_line_while: nop
		
		# plot point 1
		move $a0,       $s0
		move $a1,       $s2
		jal  draw_pixel
		
		# check if point 1 is point 2 (done)
		beq $s0, $s1, draw_line_while_done
		
		# figure twofold error
		add $t4, $s7, $s7
		
		# branch if twofold error is < dy
		blt $t4, $s5, draw_line_while_1
		
		# augment values
		add               $s7, $s7, $s5
		getCoordinates(   $s0, $t0, $t1)
		add               $t0, $t0, $s4
		formatCoordinates($s0, $t0, $t1)
				
		# goto end
		draw_line_while_1: nop
		
		# branch if twofold error is > dx
		bgt $t4, $s3, draw_line_while_2
		
		# augment values
		add               $s7, $s7, $s3
		getCoordinates(   $s0, $t0, $t1)
		add               $t1, $t1, $s6
		formatCoordinates($s0, $t0, $t1)
				
		# goto end
		draw_line_while_2: nop
		
		# continue loop
		j draw_line_while
		
		# nop
		nop
	draw_line_while_done: nop
	

	# POP
	
	# ra
	pop ($ra)
	
	# return registers (no return)
	pop ($v1)
	pop ($v0)
	
	# arg registers
	pop ($a3)
	pop ($a2)
	pop ($a1)
	pop ($a0)
	
	# save registers
	pop ($s7)
	pop ($s6)
	pop ($s5)
	pop ($s4)
	pop ($s3)
	pop ($s2)
	pop ($s1)
	pop ($s0)
	
	
	# JUMP RETURN
	jr $ra
	
#*****************************************************
# draw_rectangle:
#  Given two coordinates for the upper left and lower 
#  right coordinate, draws a solid rectangle	
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
draw_rectangle: nop

	# PSEUDO:
#	push registers
#	save args
#	x_iterator, y_iterator = first_x,first_y
#	while (True):
#		draw pixel corresponding to x and y iterators
#		x_iterator+=1
#		if (x_iterator < max_x):
#			continue
#		x_iterator=first_x
#		y_iterator+=1
#		if (y_iterator < max_y):
#			continue
#		break
#	pop registers
	

	# PUSH
	
	# save registers
	push ($s0)
	push ($s1)
	push ($s2)
	push ($s3)
	push ($s4)
	push ($s5)
	push ($s6)
	push ($s7)
	
	# arg registers
	push ($a0)
	push ($a1)
	push ($a2)
	push ($a3)
	
	# return registers
	push ($v0)
	push ($v1)
	
	# ra
	push ($ra)

	
	# STORE ARGS
	getCoordinates($a0, $s5, $s6)  # get the min x and y values
	getCoordinates($a1, $s3, $s4)  # get the max values
	move           $s0, $a2        # color
	

	# --MAIN--
	
	# fill rectangle
	move $s1, $s5  # get the x iterator
	move $s2, $s6  # get the y iterator
	draw_rectangle_loop: nop
		
		# draw the pixel
		formatCoordinates ($a0,       $s1, $s2)  # set the coordinate
		move               $a1,       $s0        # set the color
		jal                draw_pixel            # draw the pixel
		
		# increment x iterator
		addi $s1, $s1, 1
		
		# continue loop
		ble $s1, $s3, draw_rectangle_loop
		
		# reset x iterator
		move $s1, $s5 
		
		# increment y iterator
		addi $s2, $s2, 1
		
		# continue loop
		ble $s2, $s4, draw_rectangle_loop
		
		# nop
		nop
	
	
	# POP
	
	# ra
	pop ($ra)
	
	# return registers (no return)
	pop ($v1)
	pop ($v0)
	
	# arg registers
	pop ($a3)
	pop ($a2)
	pop ($a1)
	pop ($a0)
	
	# save registers
	pop ($s7)
	pop ($s6)
	pop ($s5)
	pop ($s4)
	pop ($s3)
	pop ($s2)
	pop ($s1)
	pop ($s0)
	
	
	# JUMP RETURN
	jr $ra
	
#*****************************************************
#Given three coordinates, draws a triangle
#-----------------------------------------------------
# $a0 = coordinate of point A (x0,y0) format: (0x00XX00YY)
# $a1 = coordinate of point B (x1,y1) format: (0x00XX00YY)
# $a2 = coordinate of traingle point C (x2, y2) format: (0x00XX00YY)
# $a3 = color of line format: (0x00RRGGBB)
#-----------------------------------------------------
# Traingle should look like:
#               B
#             /   \
#            A --  C
#***************************************************	
draw_triangle: nop

#	# PSEUDO
#	push registers
#	store args
#	call draw_line for A, B
#	call draw_line for A, C
#	call draw_line for B, C
#	pop registers
	
	

	# PUSH
	
	# save registers
	push ($s0)
	push ($s1)
	push ($s2)
	push ($s3)
	push ($s4)
	push ($s5)
	push ($s6)
	push ($s7)
	
	# arg registers
	push ($a0)
	push ($a1)
	push ($a2)
	push ($a3)
	
	# return registers
	push ($v0)
	push ($v1)
	
	# ra
	push ($ra)

	
	# STORE ARGS
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	

	# --MAIN--
	
	# draw A to B
	move $a0,     $s0
	move $a1,     $s1
	move $a2,     $s3
	jal draw_line
	
	# draw A to C
	move $a0,     $s0
	move $a1,     $s2
	move $a2,     $s3
	jal draw_line
	
	# draw B to C
	move $a0,     $s1
	move $a1,     $s2
	move $a2,     $s3
	jal draw_line
	
	
	# POP
	
	# ra
	pop ($ra)
	
	# return registers (no return)
	pop ($v1)
	pop ($v0)
	
	# arg registers
	pop ($a3)
	pop ($a2)
	pop ($a1)
	pop ($a0)
	
	# save registers
	pop ($s7)
	pop ($s6)
	pop ($s5)
	pop ($s4)
	pop ($s3)
	pop ($s2)
	pop ($s1)
	pop ($s0)
	
	
	# JUMP RETURN
	jr $ra	
