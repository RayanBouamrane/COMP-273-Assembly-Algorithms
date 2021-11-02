#studentName: Rayan Bouamrane	
#studentID: 260788250

# This MIPS program should sort a set of numbers using the quicksort algorithm
# The program should use MMIO

.data
#any any data you need be after this line

stringIntro: .asciiz "Welcome to QuickSort"
stringSorted: .asciiz "\nThe sorted array is: "
stringRe: .asciiz "\nThe array is re-initialized\n"

newLine: .asciiz "\n"
array1: .space 2048
array2: .space 2048
space: .asciiz " "

	.text
	.globl main

main:	# all subroutines you create must come below "main"
	
	la $a0, stringIntro 		# load Welcome string
	jal print1			# print Welcome string
	
M1:	move $s4, $0 			
	move $t6, $0			
	move $t2, $0
	move $t5, $0
	la $t4, array1
	
M2:	la $t6, array1
	la $t5, array2
	move $s4, $0
	la $a0, newLine
	jal print1
		
echo:	jal read		
	j echo

read:  	lui $t0, 0xffff 	
L1:	lw $t1, 0($t0) 		
	andi $t1, $t1, 0x0001
	beq $t1, $0, L1
	lw $v0, 4($t0) 		
	beq $v0, 99, print5
	beq $v0, 113, exit		# checks if ASCII for q (113) was input, exits if true
	beq $v0, 115, returnArr 	# checks if ASCII for s (115) was input 
	beq $v0, 8, echo		# don't echo backspaces
	sb $v0, 0($t4) 			
	addi $t4, $t4, 1
	jr $ra
	
write: 	lui $t0, 0xffff
 	
L2: 	lw $t1, 8($t0) 		
	andi $t1, $t1, 0x0001
	beq $t1, $0, L2
	sw $a0, 12($t0) 		
	jr $ra
	
loadUI:  lui $t0, 0xffff
 	
L3: 	lw $t1, 8($t0) 		
	andi $t1, $t1, 0x0001
	beq $t1, $0, L3
	sw $a0, 12($t0) 	
	jr $ra
	
returnArr:
	la $t7, array1			# $t7 stores beginning of array1

output: 			
	lb $a0, 0($t7) 
	beq $a0, $0, sortedOutput 	# loop unless null character
	addi $t7, $t7, 1
	jal write
	j output

sortedOutput: 
	la $a0, newLine
	jal print1
	
	la $a0, stringSorted
	jal print1
	
	la $t2, array2
	la $t8, array1
	jal arrayCreate
	la $s7, array2
	
	move $s6, $0
	sub $s6, $s4, 1			# array size - 1 equals largest index
	move $a0, $s7 			# array2 address is in $a0
	move $a1, $0 			# array index initialized
	move $a2, $s6 			# last index in $a2
	move $s0, $0
	move $s1, $0
	move $s2, $0
	move $s3, $0
	move $s5, $0
	move $s6, $0
	move $s7, $0
	move $t0, $0
	move $a3, $0
	move $t1, $0
	move $t5, $0
	move $t6, $0
	move $t7, $0
	move $t9, $0			
	jal quicksort
	j reset
	        
print1: 	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $t3, $a0
		
L4: 	
	lb $a0, 0($t3)
	beq $a0, $zero, exitStr
	jal write
	addi $t3, $t3, 1
	j L4
		
print2: 	
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $t3, $a0
	move $s6, $0
		
L5: 	
	lb $a0, 0($t3)
	beq $s6, 1, exitStr2
	jal loadUI
	addi $s6, $s6, 1
	addi $t3, $t3, 1
	j L5
		
exitStr:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		
exitStr2:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $s6, $0
	jr $ra
		
nextByte:
        addi $t8, $t8, 1
        
arrayCreate: 
	lbu $s1, 0($t8) 		# data from buffer loaded into $s1
	beq $s1, 32, nextByte 		# if byte is space chararacter, call nextByte
	beq $s1, 0, returnA    	# exit if character is null
	addi $t8, $t8, 1
	sub $s1, $s1, 48    		# ASCII charcter minus 48 equals its integer value
	lbu $s2, 0($t8) 		# next character stored (to check if it is another digit or a space)
	beq $s2, 32, addToArr		# if space, addToArr
	beq $s2, 0, exitArr		# We exit if there is nothing left in the file.
       	sub $s2, $s2, 48
	li $s6, 10
	mult $s1, $s6			# character was not a space, we are allowed to assume the next char was a second digit
	mflo $s0			# product moved from lo to $s0, product will always be much smaller than 32 bits
	add  $s1, $s0, $s2		# 10(d1) + d2 = number

addToArr: 
	sb $s1, 0($t2)
	addi $s4, $s4, 1		# size of list kept in $s4
	addi $t2, $t2, 1
	j nextByte

exitArr:
	addi $s4, $s4, 1
	sb $s1, 0($t2)

returnA:
	jr $ra

swap:               
	addi $sp, $sp, -12		# move stack pointer back 12 bytes, creating room for 3 words
	add $t1, $a0, $a1
	add $t9, $a0, $a2
	
	lb $s3, 0($t1)
	lb $s5, 0($t9)
	sb $s5, 0($t1)
	sb $s3, 0($t9)
	
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	
	addi $sp, $sp, 12		# restore stack to previous size
	jr $ra

divide:          
	addi $sp, $sp, -16		# move stack pointer back 16 bytes, creating room for 4 words
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $ra, 12($sp)
	move $s1, $a1			# $s1 stores lo
	move $s2, $a2			# $s2 stores hi
	add $t1, $s2, $a0		# $t1 stores index + hi
	lb $k0, 0($t1)
	addi $t3, $s1, -1
	move $s7, $s1
	addi $t5, $s2, -1

L6: 
	slt $t6, $t5, $s7		# if s7 is greater than hi-1, $t6 equals 1, branch to L8 if true
	bne $t6, $zero, L8
	add $t1, $a0, $s7
	lb $t7, 0($t1)
	slt $s6, $k0, $t7
	bne $s6, $zero, L7
	addi $t3, $t3, 1
	move $a1, $t3
	move $a2, $s7
	jal swap
	addi $s7, $s7, 1
	j L6

L7:
	addi $s7, $s7, 1
	j L6

L8:
	addi $a1, $t3, 1
	move $a2, $s2			# $a2 stores hi
	move $v0, $a1
	jal swap
	lw $ra, 12($sp)
	addi $sp, $sp, 16		# restore stack
	jr $ra

quicksort:

	addi $sp, $sp, -16		# move stack pointer back 16 bytes, creating room for 4 words
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $ra, 12($sp)
	move $t0, $a2
	bgt $a1, $t0, restorer
	jal divide
	move $s0, $v0
	lw $a1, 4($sp)
	addi $a2, $s0, -1
	jal quicksort
	addi $a1, $s0, 1
	lw $a2, 8($sp)
	jal quicksort

restorer:				# all relevant variables are restored to their
	lw $a0, 0($sp)			# previous values in memory
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra

reset:
	move $s0, $0
	move $s1, $0
	move $s2, $0
	move $s3, $0
	move $s5, $0
	move $s6, $0
	move $s7, $0
	move $t0, $0
	move $t1, $0
	move $t2, $0
	move $t5, $0
	move $t6, $0
	move $t7, $0
	move $t9, $0
	la $s7, array2
	
print3:	
	lbu $t9, 0($s7)
	bgt $t9, 9, intTooLarge	# call intTooLarge if number larger than 9
	addi $t9, $t9, 48
	sb $t9, 0($s7)
	la $a0, 0($s7)
	jal print2
	j print4
 
intTooLarge:
	div $k1, $t9, 10
	mfhi $t7 
	mflo $t6
	addi $t7, $t7, 48
	addi $t6, $t6, 48
	sb $t6, 0($s7)
	la $a0, 0($s7)
	jal print2
	sb $t7, 0($s7)
	la $a0, 0($s7)
	jal print2

print4:
	la $a0, space
	jal print2
	addi $s7, $s7, 1
        addi $a3, $a3, 1
	beq $a3, $s4, storespace 
	j print3
	
print5:
	la $a0, stringRe
	jal print1
	 
clearArray1:	
	lb $s2, 0($t6)
	beq $s2, $0, clearArray2
	move $s2, $0
	sb $s2, 0($t6)
	addi $t6, $t6, 1
	j clearArray1

clearArray2:
	lb $s2, 0($t5)
	beq $s2, $0, M1
	move $s2, $0
	sb $s2, 0($t5)
	addi $t5, $t5, 1
	j clearArray2

printStore:
	move $k1, $0
	addi $k1, $k1, 32
	sb $k1, 0($t4) 
	addi $t4, $t4, 1
	j M2

exit: