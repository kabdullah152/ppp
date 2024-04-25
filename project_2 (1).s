.data
newline: .asciiz "\n" #creates new line
userInput: .space 1001 #takes in user input of 1000 spaces + \0 null
number: .asciiz "0123456789" #first asciiz sequence to check through, all valid digits
alphaOne: .asciiz "abcdefghijklmnopqrstuvwxy" #since base is 35, last valid letter is y...all lowercase letters to y
alphaTwo: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXY" #all uppercase letters to x
NotApplicable: .asciiz "N/A" #so "N/A" can be returned if no valid digits or letters
semiColon: .asciiz ";" #checks for semicolon

.text
main:
li $t0, 0 #count to return digit or letter value
li $t1, 0 #iteration through input length... used for tracking
li $s6, 0 #acts as a flag between g and h math...makeshift boolean
li $t4, 0 #counter for invalid digits/letter
li $s1, 0 #represents variable G
li $s0, 0 #represents variable H

la $a0, semiColon #loading semicolon into address
move $t7, $a0 #move semicolon into t7
lb $t6, 0($t7) #loads the direct value of semicolon
la $a0, userInput # load the user input into this address
li $a1, 1001 # total expected characters for user input
li $v0, 8 #user input call
syscall #formality

la $a0, userInput #load user input into address
move $s5, $a0 #move stored value into $s5
jal reinitialize #calls reinitialize
j num #calls num

reinitialize:
la $a0, number #number sequence loaded into $a0
move $s2, $a0 #sequence moved to $s2

la $a0, alphaOne #alphabet lowercase sequence loaded into $a0
move $s3, $a0 #sequence moved to $s3
la $a0, alphaTwo #alphabet uppercase loaded into $a0
move $s4, $a0 #$sequence moved to $s4
jr $ra #return to previous function

num:
bgt $t0, 9, loweralph
lb $t2, 0($s5) #loading the first character of user input into $t2
lb $t3, 0($s2) #number sequence will be loaded here, starts at beginning
beq $t2, $t6, blue #branches to blue for NA flag
beq $t2, $t3, calcG #if character at element equals element in sequence, branch
addi $t0, $t0, 1 #count variable for digit or letter value is incremented by 1
addi $s2, $s2, 1 #goes up the number sequence by 1
j num #loops pointer and counter until condition is broken

loweralph:
bgt $t0, 0x22, red #setting iteration limit for 34
lb $t3, 0($s3) #lower case sequence will be loaded here, starts at beginning
beq $t2, $t3, calcG #if character at element equals element in sequence, branch
addi $t0, $t0, 1 #count variable for digit or letter value is incremented by 1
addi $s3, $s3, 1 #goes up the lowercase alphabet sequence by 1
j loweralph #function loop

upperalph:
bgt $t0, 0x22, blue #branch to invalid counter if exceeds limit
lb $t3, 0($s4) #upper case sequence will be loaded here, starts at beginning

beq $t2, $t3, calcG #if character at element equals element in sequence, branch
addi $t0, $t0, 1 #count variable for digit or letter value is incremented by 1
addi $s4, $s4, 1 #goes up the uppercase alphabet sequence by 1
j upperalph #loop

red:
li $t0, 0xA #count is reset for the case of uppercase letters
j upperalph #jump to upperalph 

blue:
beqz $t2, finalCalc
li $t0, 0 #resets $t0 counter
addi $s5, $s5, 1 #increments pointer on $s5
beq $t2, $t6, purple #semicolon check
jal reinitialize #jump to reinitialize to reset everything.

j num #now this calculation runs multiple times

purple:
beq $s6, 0, NA #if no math was done, branch to NA
sub $s0, $s0, $s1 #calculation of g - h
move $a0, $s0
li $v0, 1
syscall
jal printColon

li $s0, 0 #reset g
li $s1, 0 #reset h
li $s6, 0 #reset flag

jal reinitialize
j num

calcG:
beq $s6, 2, calcH #checks flag to switch to h calculation
li $s6, 1 #sets flag to 1
add $s0, $s0, $t0 #adds counted value to G
li $t0, 0 #resets $t0
addi $s5, $s5, 1 #Increments the user input up one
addi $s6, $s6, 1 #flag variable...acts as boolean

jal reinitialize
j num

calcH:
add $s1, $s1, $t0 #adds counted value to H
li $t0, 0 #resets $t0
addi $s5, $s5, 1 #increments the user input pointer
addi $s6, $s6, -1 #flag variable is set back to 1
jal reinitialize
j num

finalCalc:
beqz $s6, NA
sub $s0, $s0, $s1 #subtract G from H

move $a0, $s0 #calculated value g-h is moved into $a0
li $v0, 1 #print integer
syscall #formality
j exit #jump to exit

NA:
la $a0, NotApplicable #NA is being loaded into $a0
li $v0, 4 #address is printed
syscall #formality
beqz $t2, exit
jal printColon

j num

printColon:
la $a0, semiColon
li $v0, 4
syscall

jr $ra

exit:
li $v0, 10 #exit call
syscall #formality
