.data

pattern: 	.space 17	# array of 16 (1 byte) characters (i.e. string) plus one additional character to store the null terminator when N=16

N_prompt:	.asciiz "Enter the number of bits (N): "
newline: 	.asciiz "\n"
zeroBit:	.byte	'0'
oneBit:		.byte	'1'
null: 		.byte	'\0'

.text

#----------------------------------------------
#
# Fully Functional C Code for reference
#
# include<stdio.h>
# char pattern[17] = {0};
# void bingen( unsigned int N, unsigned int n ); 
#
# int main( int argc, char** argv ) {
#
#	 unsigned int N = 0;
#	 // You can assume the user enters a
#	 // value of N >= 1 and N <= 16.
#	 // i.e. no error checking is necessary
#	 printf( "Enter the number of bits (N): ");
#	 scanf("%u", &N );
# 
#	 unsigned int n = N;
#	 pattern[N] = '\0'; // Null terminate the string
#	 bingen( N, n );
#	 return 0;
# }
# END OF MAIN ----------------------------------------
main:
la $s0, pattern		#put address of pattern array in s0

addi $v0, $0, 4		#print a string
la, $a0, N_prompt	#print prompt asking for # of bits (N)
syscall

addi $v0, $0, 5		# read in an int, i.e. # of bits (N)
syscall

add $s1, $v0, $0	#store unsigned integer N in s1

addu $a0, $0, $s1	# put N in a0 to be used on stack later
addu $a1, $0, $s1	# unsigned int n = N

add $t0, $0, $0		#t0 = 0

nullTerm:

sll $t1, $t0, 2		# t0 * 4 for offset

slt $t2, $t0, $s1	# if offset < N, becomes 1, else 0
beq $t2, $0, continue	#if offset > N, continue

add $t3, $s0, $t1	# &pattern
lb $t1, null	
sb $t1, 0($t3)		#pattern[N*4] = '\0'

addi $t0, $t0, 1	# 
j nullTerm

continue:

jal bingen

j exit

# void bingen( unsigned int N, unsigned int n ) {
#    if ( n > 0 ) {
#        pattern[N-n] = '0';
#        bingen( N, n - 1 );
#        pattern[N-n] = '1';
#        bingen( N, n - 1 );
#    } else printf( "%s\n", pattern );
# }
#
#----------------------------------------------

bingen:

add $t4, $0, $0		#clear 4 5 and 6 for recursion reuse
add $t5, $0, $0
add $t6, $0, $0 

addi $sp, $sp, -8
sw $ra, 4($sp)
sw $fp, 0($sp)
addi $fp, $sp, 4

addi $sp, $sp, -8
sw $a0, 4($sp)		# N (a0) on the stack
sw $a1, 0($sp)		# n (a1) on the stack

addu $s1, $0, $a0	# N in s1
addu $s2, $0, $a1	# n in s2

addi $sp, $sp, -8
sw $s1, 4($sp)		# N (s1) on the stack
sw $s2, 0($sp)		# n (s2) on the stack

slt $t4, $0, $a1	# if (n > 0), 1 if true 0 if false
beq $t4, $0, else

subu $t5, $s1, $s2	# t5 = N-n
add $t6, $s0, $t5	# &pattern[N-n]
lb $t7, zeroBit		# pattern[N-n] = '0'	
sb $t7, 0($t6)		

add $a0, $s1, $0	#a0 = N
subi $a1, $s2, 1	#a1 = n-1

jal bingen		#first bingen

lw $s1, 4($sp)		# load N off of the stack
lw $s2, 0($sp)		# load n off of the stack

subu $t5, $s1, $s2	# t5 = N-n
addu $t6, $s0, $t5	# &pattern[N-n]

lb $t7, oneBit		# pattern[N-n] = '1'	
sb $t7, 0($t6)

addu $a0, $s1, $0	# a0 = N
subi $a1, $s2, 1	# a1 = n-1

jal bingen 		# second bingen

lw $a0, 4($sp)
lw $a1, 0($sp)

j end

else: 
addi $v0, $0, 4		#print results from pattern array
la $a0, 0($s0)
syscall


addi $v0, $0, 4
la $a0, newline
syscall


end:
addi $sp, $fp, 4	#pop off stack and return
lw $ra 0($fp)
lw $fp, -4($fp)
jr $ra

exit:                     
  addi $v0, $0, 10      	# system call code 10 for exit
  syscall               	# exit the program