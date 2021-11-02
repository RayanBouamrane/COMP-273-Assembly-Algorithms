#studentName: Rayan Bouamrane
#studentID: 260788250

# This MIPS program should count the occurence of a word in a text block using MMIO

.data
#any any data you need be after this line 

buffer1:	.space 600
buffer2:	.space 600
word1:		.space 4

numWords:	.asciiz " Word Count\n"
textString:	.asciiz "Enter the text segment:\n   "
searchString:	.asciiz "\nEnter the search word:\n   "
pressString:	.asciiz "\npress 'e' to enter another segment of text or 'q' to quit.\n"

string1:	.asciiz "\nThe word '"
string2:	.asciiz "' occured "
string3:	.asciiz " time(s). "

		.text
		.globl main

main:	# all subroutines you create must come below "main"	
	la $a0, numWords
	jal write

M1:	la $a0, textString
	jal write
	la $a0, buffer1	
	jal read
	la $a0, buffer1	
	jal write
	la $a0, searchString
	jal write
	la $a0, buffer2	
	jal read
	la $a0, buffer2	
	jal write
	la $a0, buffer1	
	jal find
	move $a0, $v0
	jal numbers
	la $a0, string1	
	jal write
	la $a0, buffer2	
	jal write
	la $a0, string2	
	jal write
	la $a0, word1
	jal write
	la $a0, string3	
	jal write
	la $a0, pressString
	jal write
	j M2

numbers:
	bgt $a0, 9, checkWord
	addi $a0, $a0, 48
	
	la $t5, word1
	sw $a0, 0($t5)
	jr $ra
		
checkWord:	
	li $t0, 10
	div $a0, $t0		# divide $a0 contents by 10
	mfhi $t1
	mflo $t2
	addi $t1, $t1, 48	# add 48 to convert to corresponsing ASCII
	addi $t2, $t2, 48
		
	la $t5 word1,
	sb $t2, 0($t5)
	addi $t5, $t5, 1
	sb $t1, 0($t5)
	jr $ra		

write: 	lui $t0, 0xffff 	# 0xffff0000 is loaded
	lb $t3, 0($a0)

L1:	beqz $t3, return	# jump to return address if no value found
	sb $t3, 12($t0)	

L2: 	lw $t1, 8($t0)
	beq $t1,$zero,L2	# check if blank
	addi $a0, $a0, 1		
	lb $t3, 0($a0)			
	j L1
		
return:	jr $ra								
		
M2:	lui $t0, 0xffff	
		
pressStrCheck:	
	lw $t1, 0($t0)	
	andi $t1, $t1, 0x0001
	beq $t1, $zero, pressStrCheck	#if zero, loop again, pressString should not be displayed			
	lb $t2, 4($t0)
	beq $t2, 113, exit
	j clearBuffers

read:	lui $t0, 0xffff	
						
L3:	lw $t1, 0($t0)			
	andi $t1, $t1, 0x0001		
	beq $t1, $zero, L3
	lb $t2, 4($t0)			
	beq $t2, 10, return		
	sb $t2, 0($a0)		# store keys typed by user
	addi $a0, $a0, 1		
	j L3			

find:	li $v0, 0			

restoreBuffer2:
	la $s0, buffer2		
	
L4: 	lb $t0, 0($a0)			
	beq $t0, 32, wordCount	# if space entered, jump to wordcount
	beqz $t0, finalCall	# if $t0 null jump to finalCall
	lb $t1, 0($s0)			
	bne $t0, $t1, L5	
	addi $a0, $a0, 1		
	addi $s0, $s0, 1
	j L4

finalCall:
	lb $t9, 0($s0)
	bnez $t9, return
	addi $v0, $v0, 1
	j return

wordCount:	
	lb $t9, 0($s0)			
	beqz $t9, increment
	addi $a0, $a0, 1	
	j restoreBuffer2

increment:
	addi $v0, $v0, 1		
	addi $a0, $a0, 1			
	j restoreBuffer2
						
L5:	addi $a0, $a0, 1		
	lb $t3, 0($a0)			
	beqz $t3, return
	bne $t3, 32, L5	
	addi $a0, $a0, 1
	j restoreBuffer2		
		
clearBuffers:	
	add $t0, $t0, $zero		
	la $t1, buffer1	
	la $t2, buffer2		

L6:	lb $t3, 0($t1)			
	beq $t3, $zero, L7String
	sb $t0, 0($t1)			
	addi $t1, $t1, 1		
	j L6			

L7String:	
	lb $t4, 0($t2)			
	beq $t4, $zero, M1
	sb $t0, 0($t2)			
	addi $t2, $t2, 1		
	j L7String
	
exit: