############################################
# NAME: Barkin
# SURNAME: Karadeniz
############################################

.data
	correct_number:		.asciiz 	"0000 0000 0000 0000"		## returns 0 (==> correct)     
	wrong_number:		.asciiz 	"4748 3726 2746 4926"		## returns 6 (==> wrong)
	
	STRING_1:			.asciiz		"Your algorithm returned: "
	STRING_2:			.asciiz		"The credit card number is correct."
	STRING_3:			.asciiz		"The credit card number is NOT correct!"
		

#
# main
#

.text
.globl main

main:
	addi $sp, $sp, -8		## Non-leaf function, make space for 2 reg
	sw $ra, 0($sp)			## save return address on stack
	sw $s0, 4($sp)			## save previous value of s0 on stack
	
	la $a0, correct_number		## load address of number as argument
	jal luhn			## call luhn-function
	move $s0, $v0			## save returned value
	
	la $a0, STRING_1		## print STRING_1
	jal print_string
	
	move $a0, $s0			## print result of luhn-algo
	jal print_int
	jal print_new_line
	
	li $t0, 0
	beq $s0, $t0, main_is_zero	## if s0 != 0
	
	la $a0, STRING_3			## then 
	jal print_string
	j main_end
	
main_is_zero:					## else
	la $a0, STRING_2
	jal print_string

main_end:	
	lw $s0, 4($sp)			## restore previous value of s0 from stack
	lw $ra, 0($sp)			## restore return address from stack
	addi $sp, $sp, 8		## free memory

	li $v0, 10				## exit syscall
	syscall
	


# $a0: int to print

print_int:
	li $v0, 1
	syscall

	jr $ra
	
# $a0: char to print

print_char:
	li $v0, 11
	syscall
	
	jr $ra

print_new_line:
	addi $a0, $0, 0x0A		## ASCII \n
	li $v0, 11
	syscall

	jr $ra

# $a0: string address to print

print_string:
	li $v0, 4
	syscall

	jr $ra



luhn:
	
	li $t1, 18 	# Laenge
	move $t2, $zero #Index
	move $t3, $zero	#Parity
	move $v0, $zero
	
	
	for:
		bgt $t2, $t1, endfor
		add $t4, $a0, $t2	#t4 = &a0[t2] 
		lb $t5, 0($t4)		#$t5 = a0[t2]
		bgt $t5, 57, else
		addi $t5, $t5, -48	#ASCII
		li $t6, -16	
		bne $t6, $t5, not_space
		bgt $t5, 57, else
		addi $t2, $t2, 1
		j for
	
	not_space:			#runs if it's not a space
		blt $t2, 4, array1	#for the characters between 18th-14th digit
		blt $t2, 9, array2	#for the characters between 14th-9th digit
		blt $t2, 14, array3	#for the characters between 9th-4th digit
		ble $t2, 18, array4	#for the characters between 4th-0th digit
		
	array1:				#for the characters between 18th-14th digit
		andi $t7, $t2, 1
		beq $t7, $zero, gerade
		beq $t7, 1, ungerade
	
	array2:				#for the characters between 14th-9th digit
		andi $t7, $t2, 1
		beq $t7, $zero, ungerade
		beq $t7, 1, gerade
		
	array3:				#for the characters between 9th-4th digit
		andi $t7, $t2, 1
		beq $t7, $zero, gerade
		beq $t7, 1, ungerade
		
	array4:				#for the characters between 4th-0th digit
		andi $t7, $t2, 1
		beq $t7, $zero, ungerade
		beq $t7, 1, gerade
		
	gerade:				#to double the digit and add it to the result of thge luhn algorithm
		add $t8, $t5, $t5
		bge $t8, 10, zwei_stellig
		add $v0, $v0, $t8
		addi $t2, $t2, 1
		j for
	
	ungerade:			#to add it to the result of thge luhn algorithm
		add $v0, $v0, $t5
		addi $t2, $t2, 1
		j for
		
	zwei_stellig:			#to add numbers of two digits
		subi $t8, $t8, 9
		add $v0, $v0, $t8
		addi $t2, $t2, 1
		j for
	else:
		blt $t5, 48, error
		
	error:
		li $v0, -1			## return -1 for error
		jr $ra
	endfor:
		
		rem $v0, $v0, 10
		jr $ra				## jump back
	
	

