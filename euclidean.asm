# xSpim Memory Demo Program

#  Data Area
.data

space:
    .asciiz " "

newline:
    .asciiz "\n"

dispArray_P:
    .asciiz "\nArray P:\n"

dispArray_Q:
    .asciiz "\nArray Q:\n"

convention:
    .asciiz "\nConvention Check\n"

euclideanDistance:
    .asciiz "\nEuclidean Distance:\n"

arrayP:
    .word -20 29 -187 -66 331 39 -220 455 9

arrayQ:
    .word -21 28 -188 -67 332 40 -221 454 10

#Text Area (i.e. instructions)
.text

main:
    ori     $v0, $0, 4          
    la      $a0, dispArray_P
    syscall

    la      $s0, arrayP
    la      $s1, arrayQ
    ori     $s2, $0, 9 # array size

    add     $a0, $0, $s0
    add     $a1, $0, $s2
 
    jal     DispArray

    la      $a0, dispArray_Q
    syscall

    add     $a0, $0, $s1
    add     $a1, $0, $s2
 
    jal     DispArray

    ori     $s3, $0, 0
    ori     $s4, $0, 0
    ori     $s5, $0, 0
    ori     $s6, $0, 0
    ori     $s7, $0, 0
    
    add     $a0, $0, $s0
    add     $a1, $0, $s1
    add     $a2, $0, $s2

    jal     PrintEuclidean

    add     $s3, $s3, $v0
    add     $s3, $s3, $s4
    add     $s3, $s3, $s5
    add     $s3, $s3, $s6
    add     $s3, $s3, $s7

    ori     $v0, $0, 4          
    la      $a0, euclideanDistance
    syscall

    ori     $v0, $0, 1
    add     $a0, $0, $s3
    syscall

    ori     $v0, $0, 4          
    la      $a0, newline
    syscall

    j       Exit

DispArray:
    addi    $t0, $0, 0 
    add     $t1, $0, $a0

dispLoop:
    beq     $t0, $a1, dispend
    sll     $t2, $t0, 2
    add     $t3, $t1, $t2
    lw      $t4, 0($t3)

    ori     $v0, $0, 1
    add     $a0, $0, $t4
    syscall

    ori     $v0, $0, 4
    la      $a0, space
    syscall

    addi    $t0, $t0, 1
    j       dispLoop    

dispend:
    ori     $v0, $0, 4
    la      $a0, newline
    syscall
    jr      $ra 

ConventionCheck:
    addi    $t0, $0, -1
    addi    $t1, $0, -1
    addi    $t2, $0, -1
    addi    $t3, $0, -1
    addi    $t4, $0, -1
    addi    $t5, $0, -1
    addi    $t6, $0, -1
    addi    $t7, $0, -1
    ori     $v0, $0, 4
    la      $a0, convention
    syscall
    addi $v0, $zero, -1
    addi $v1, $zero, -1
    addi $a0, $zero, -1
    addi $a1, $zero, -1
    addi $a2, $zero, -1
    addi $a3, $zero, -1
    addi $k0, $zero, -1
    addi $k1, $zero, -1
    jr      $ra

Squared:
    mult $a0, $a0
    mflo $v0

    addiu $sp, $sp, -8
    sw $s0, 0($sp)
    sw $ra, 4($sp)
    move $s0, $v0

    jal ConventionCheck

    move $v0, $s0
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addiu $sp, $sp, 8

    jr $ra
    
SquareRoot:
    # using $t0-3
    move $t0, $a0
    move $t1, $zero
    move $t2, $a0,
    li $t9, 2
    div $a0, $t9
    mflo $t3

sqrtLoop:
    div $t0, $t2
    mflo $t4
    add $t4, $t4, $t2
    div $t4, $t9
    mflo $t2
    addiu $t1, $t1, 1
    bge $t1, $t3, sqrtEnd
    j sqrtLoop

sqrtEnd:
    move $v0, $t2

    addiu $sp, $sp, -8
    sw $s0, 0($sp)
    sw $ra, 4($sp)
    move $s0, $v0

    jal ConventionCheck

    move $v0, $s0
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addiu $sp, $sp, 8

    jr $ra

Exit:
    ori     $v0, $0, 10
    syscall

# COPYFROMHERE - DO NOT REMOVE THIS LINE

PrintEuclidean:
    # TODO: write your code here
    # $a0 stores the address of the arrayP
    # $a1 stores the address of the arrayQ 
    # $a2 stores the n in given n-dimensional Euclidean space
	
    #first, store all the stuff that should not be overwritten in the stack
    #increment the stack pointer:
    addiu $sp $sp -24
    sw $s0 0($sp)   #array of Ps
    sw $s1 4($sp)   #array of Qs
    sw $s2 8($sp)   #n dimentions, essentially the # of times the thing should loop for
    sw $s3 12($sp)  #holds # of times eclid func has looped
    sw $s4 16($sp)  #holds value so far
    sw $ra 20($sp)  #especially important

    li $s3 0
    li $s4 0

    #both Squared and SquareRoot does the stuff on a0 and leaves the end value in v0, keep in mind when jal-ing
    #therefore, I will store temp P - Q value in a0

    euclidLoop:

    #check to terminate loop
    bge $s3 $s2 loopEnd

        sw $t0 0($s0)   #value of curr P
        sw $t1 0($s1)   #value of curr Q

        #store P - Q in a0 and then jal the sqrt func
        sub $a0 $t0 $t1
        jal Squared
        #now the squared result is in $v0, so += it into $s4
        add $s4 $s4 $v0

        #also, print out the curr value of (P-Q)^2
        move $a0 $v0
        li $v0 1
        syscall

        #after-main-action incrementing:
        addiu $s0 $s0 4
        addiu $s1 $s1 4
        addu $s3 $s3 1

    j euclidLoop

    loopEnd:
    #time to square the end value, and restore everything as well
    #remember to put final end value in the $v0 register

    move $a0 $s4
    jal SquareRoot

    #since the value of the final end value is still in $v0, no need to move it anywhere

    #restore all the schizz:
    lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $ra 20($sp)

    #restore where the stack pointer is
    addiu $sp $sp 24

    # Do not remove this line - kk boss
    jr      $ra
