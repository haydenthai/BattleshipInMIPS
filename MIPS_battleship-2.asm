# File:			Battleship By Hayden Thai
#
#Author:			Hayden Thai (hthai7679@sdsu.edu)
#	
#Contributors:		None
#
.data 

	#STRINGS
	welcome: 			.asciiz 		"======================================================\nBATTLESHIP[5x5]\n======================================================\n\n\nBy Hayden Thai\n\n\n\n\tRules:\nA.     Battleship consists of 2 players. You and another player\nB.     You must manually input coordinates\nC.     There are 3 ships for each player. Each ship holds 1 cell\nD.     The game is played on a 3x3 grid until all of one's player's boats are             destroyed\nE.      If you hit a ship then you get to shoot again\nF.      You can not shoot in the same cell. The game is intended to be played by          these rules\n"
	askRow: 			.asciiz 		"Enter row(0-4)\n"
	askCol: 			.asciiz 		"Enter col(0-4)\n"
	enterSeed: 			.asciiz 		"Enter seed:\n"
	playerWins: 			.asciiz 		"=========\nPLAYER X WINS\n=========\nTotal shots: X \nHit/Miss Percent: %"	
	playerStats: 			.asciiz 		"=========\nPLAYER X STAT\n=========\nTotal shots: X \nHit/Miss Percent: %"
	playerXGoesFirst: 		.asciiz 		"Player X goes first!"
	playerOnesTurn: 		.asciiz 		"PLAYER ONE'S TURN"
	playerTwosTurn: 		.asciiz 		"PLAYER TWO'S TURN"
	newLine: 			.asciiz 		"\n"
	HitMessage: 			.space 			50
	MissMessage: 			.space 			50
	
	
	#INT ARRAYS
	hitMissCounter: 		.word 		0,0,0,0 		#player 1 miss, player 1 hit, player 2 miss, player 2 hit
	numShips: 			.word 		5, 5 			# to access numships[1]  do baseAddr + 4 * index

	#DOUBLE *used to calculate hit %"*
	oneHunna: 			.double 	100

	#GAMEBOARDS		
	playerOneBoard: 		.space 		200
	playerOneViewBoard: 		.space 		200		
	playerTwoBoard: 		.space 		200
	playerTwoViewBoard: 		.space 		200

.text

# s0 holds enemyBoard, 
# $s1 holds player (0 for player 1 & 1 for player 2), 
# $s2 holds your viewing board
# $s3 holds the array numShips
# $s4 holds the value of hit 

main:	

	jal initializeGame
	
	la $s3, numShips
	begin: bnez $s1, player2
	
	
		player1:					# $s0 holds player2 Board
		
			la  $s5, hitMissCounter	# $s5 = numMiss[0]
			addi $s6, $s5, 4		# $s6 = numHits[0]
			
			lw $t6, 4($s3)			# Load ship count into $t6
			addi $t5, $s3, 4		# fetch memory address of player 2 and stores in $t5
			
			li $v0, 55
			li $a1, 1
			la $a0, playerOnesTurn
			syscall
			
			la $s0, playerOneViewBoard
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal printBoard
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			
			la $s0, playerTwoBoard
			la $s2, playerOneViewBoard
			
			 
				
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal getShot				# $s4 returns 0 for miss, 1 for hit
			lw $ra, 0($sp)
			addi $sp, $sp, 4  	
			
			
			ble $t6, 0, endGame			# if ( sunkShips[1] < 0)
			bne $s4, 1, player2			# if( isHit == 0  ) branch
			j player1
			
		
		player2:
			
			la  $s5, hitMissCounter	
			addi $s5, $s5, 8		# $s5 = numMiss[0]
			addi $s6, $s5, 4		# $s6 = numHits[0]
		
			
			li $v0, 55
			li $a1, 1
			la $a0, playerTwosTurn
			syscall
			
			la $s0, playerTwoViewBoard
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal printBoard
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			
			la $s0, playerOneBoard
			la $s2, playerTwoViewBoard
			
			
			lw $t6, 0($s3)		#loads the Player 1 ship count into $t6
			addi $t5, $s3, 0	#fetches memroy address of player 1 and stores in $t5		

			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal getShot
			lw $ra, 0($sp)
			addi $sp, $sp, 4 
			
			
	
			ble $t6, 0, endGame			#if ( sunkShips[0] < 0)	branch to end if someone's ships are 0
			bne $s4, 1, player1			# if (isHit == 1) branch to player 2 if not go to player 1
				j player2


#
#	This function calls the print stats in the order of winner first and loser second
#
#	input -> $s1 player who wins
#
#	output -> none
endGame:

	playerOneWinsGame: bnez $s1, playerTwoWinsGame
	
		la $s6, playerWins		
		la $s4, hitMissCounter	#load address of misses into $s4
		addi $s5, $s4, 4		#load address of hits into $s5
	
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal printStats			
		lw $ra, 0($sp)
		addi $sp, $sp, 4 
	
	
		li $s1, 1
		la $s6, playerStats
		la $s4, hitMissCounter	
		addi $s4, $s4, 8		# load address of misses into $s4
		addi $s5, $s4, 4		# load address of hits into $s5
	
	
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal printStats			
		lw $ra, 0($sp)
		addi $sp, $sp, 4 
	
		j afterPlayerTwoWinsGame
		
	playerTwoWinsGame:
	
		la $s6, playerWins
		la $s4, hitMissCounter	
		addi $s4, $s4, 8		#load address of misses into $s4
		addi $s5, $s4, 4		#load address of hits into $s5
	
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal printStats			
		lw $ra, 0($sp)
		addi $sp, $sp, 4 
	
	
		li $s1, 0
		la $s6 playerStats
		la $s4, hitMissCounter	#load address of misses into $s4
		addi $s5, $s4, 4		#load address of hits into $s5
	
	
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal printStats			
		lw $ra, 0($sp)
		addi $sp, $sp, 4 
	
	afterPlayerTwoWinsGame:
	
		j end

#
#	this funciton prints the winner and displays the stats of each player
#	
#	inputs: 	$s6 -> String to be printed 
#			$s1 -> player
#			$s4 -> numHits, $s5 -> numMiss
#
#	outputs: none
printStats:
		
		# This branch determines the winner
			bnez $s1, winnerIsPlayer2
				li $t3, 49	#1
				sb $t3, 17($s6)
				j afterIsWinnerPlayer2
				
				winnerIsPlayer2:
				li $t3, 50, #2
				sb $t3, 17($s6)
				
			afterIsWinnerPlayer2:
			
			lw $t0, ($s5)	# $t0 gets numMiss
			lw $t1, ($s4)	# $t1 gets numHits
			
			add $t2, $t0, $t1 #STORE THE VAL OF TOTAL SHOTS in $t2
			
			addi $a1, $s6, 47	#address of the int
		     	move $a0, $t2		#a0 gets the the integer(total shots)
		     	
		     	addi $sp, $sp, -4
			sw $ra, 0($sp)
		     	jal int2str			#convert total shots to string
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			
			
			lw $t0, ($s5)	# $t0 gets numMiss
			lw $t1, ($s4)	# $t1 gets numHits
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
		     	jal calcHitPercent
			lw $ra, 0($sp)
			addi $sp, $sp, 4
		     			
									
			li $v0, 58		#MessageDialogFloat, prints a float at the end of the string
			move $a0, $s6	#load string into $a0
		     	syscall	
		     	
		     	jr $ra

#
#		Calculate hit percentage
#
#inputs:	$t1 ->  numHits
#		$t0 ->  numMiss
#
#outputs	$f12 -> hit/miss ratio
#
calcHitPercent:
	mtc1 $t1, $f2		#f2 gets numMiss
	cvt.d.w $f2, $f2		#converts numHits into a float 

	mtc1 $t0, $f0		#f0 gets numHits		
	cvt.d.w $f0, $f0		#converts numMiss into a float

	add.d $f2, $f2, $f0	# totalHits = numHits + numMiss
	
	div.d $f12, $f0, $f2	#numHits / totalHits stored in $f12
	l.d $f6 oneHunna	#f12 *= 100
	mul.d $f12, $f12, $f6	
	jr $ra	
				
#
#	This function was written by Payas Krishna on January 3, 2020
#	src code can be found here: https://stackoverflow.com/questions/46917337/simple-mips-function-to-convert-integer-to-string?rq=1
#	
# inputs : $a0 -> integer to convert
#             $a1 -> address of string where converted number will be kept
# outputs: none	
int2str:
	
	addi $sp, $sp, -4       	# to avoid headaches save $t- registers used in this procedure on stack
	sw   $t0, ($sp)           	# so the values don't change in the caller. We used only $t0 here, so save that.
	bltz $a0, neg_num         	# is num < 0 ?
	j    next0                		# else, goto 'next0'

	neg_num:                  	# body of "if num < 0:"
	li   $t0, '-'
	sb   $t0, ($a1)           	# *str = ASCII of '-' 
	addi $a1, $a1, 1         	# str++
	li   $t0, -1
	mul  $a0, $a0, $t0        	# num *= -1

	next0:
	li   $t0, -1
	addi $sp, $sp, -4         	# make space on stack
	sw   $t0, ($sp)           	# and save -1 (end of stack marker) on MIPS stack

	push_digits:
	blez $a0, next1           	# num < 0? If yes, end loop (goto 'next1')
	li   $t0, 10              		# else, body of while loop here
	div  $a0, $t0              # do num / 10. LO = Quotient, HI = remainder
	mfhi $t0                  # $t0 = num % 10
	mflo $a0                  # num = num // 10  
	addi $sp, $sp, -4         # make space on stack
	sw   $t0, ($sp)           # store num % 10 calculated above on it
	j    push_digits          # and loop

	next1:
	lw   $t0, ($sp)           # $t0 = pop off "digit" from MIPS stack
	addi $sp, $sp, 4          # and 'restore' stack

	bltz $t0, neg_digit       # if digit <= 0, goto neg_digit (i.e, num = 0)
	j    pop_digits           # else goto popping in a loop

	neg_digit:
	li   $t0, '0'
	sb   $t0, ($a1)           # *str = ASCII of '0'
	addi $a1, $a1, 1          # str++
	j    next2                # jump to next2
	
	pop_digits:
	bltz $t0, next2           # if digit <= 0 goto next2 (end of loop)
	addi $t0, $t0, '0'        # else, $t0 = ASCII of digit
	sb   $t0, ($a1)           # *str = ASCII of digit
	addi $a1, $a1, 1          # str++
	lw   $t0, ($sp)           # digit = pop off from MIPS stack 
	addi $sp, $sp, 4          # restore stack
	j    pop_digits           # and loop

	next2:
	#sb  $zero, ($a1)          # *str = 0 (end of string marker)

	lw   $t0, ($sp)           # restore $t0 value before function was called
	addi $sp, $sp, 4          # restore stack
	jr  $ra                   # jump to caller	
	
				
#	This function asks the user for a coordinate and checks if it is a hit in checkShot
#	If it's a hit then it displays a hit message 
#	
#	inputs: 	$s0  -> enemy board 	
#			$s2 -> current player's view board
#						
#	outputs: 	$s4 -> isHit (0 for miss, 1 for hit)						
getShot:	
	li $v0, 51
	
	la $a0, askRow
	syscall
	move $t0, $a0
	
	la $a0, askCol
	syscall
	move $t1, $a0

	checkShot: 
	##	1. Check if the shot is a hit in $s0(the enemy board)
	
	mul $t2, $t0, 21 		#row*12
	mul $t3, $t1, 4		#col*4
	add $t2, $t2, $t3 		#row*12 + col*4
	addi $t2, $t2, 18 		# OFFSET = row*12 + col*4 + 18 * you add 18 to offset "PLAYER X'S BOARD\n[" *
	
	add $t4, $s2, $t2		# t4 gets the offset of view board array($s2)+ offset ($t2)
	add $t3, $s0, $t2 		# t3 gets address of board array + offset
	
	lb $t9, ($t3)			#loads the value at the memory address of the offset(ie loads the val at [row][col])
	beq $t9, 32, miss 		# if shot is water then branch to "miss:"
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal playHitSound
		lw $ra, 0($sp)
		addi $sp, $sp, 4  
		
		li $t9, 72			# load H into $t3
		sb $t9, ($t4)		# Store H into the view board
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal loadHitMessage
		lw $ra, 0($sp)
		addi $sp, $sp, 4  
		
		li $v0, 55
		li $a1, 1
		la $a0, HitMessage
		syscall
		
		lw $t0, ($s6)
		addi $t0, $t0, 1
		sw $t0, ($s6)		# numhits[player]++
		
		li $s4, 1			# isHit = 1;
		
		addi $t6, $t6, -1
		sw $t6, ($t5)		# numShips[player]--;
		j afterMiss
		
	miss:
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal playMissSound
		lw $ra, 0($sp)
		addi $sp, $sp, 4 
		
		li $t9, 77			# load M into $t3
		sb $t9, ($t4)		# Store M into the view board
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal loadMissMessage
		lw $ra, 0($sp)
		addi $sp, $sp, 4  
		
		li $v0, 55
		li $a1, 1
		la $a0, MissMessage
		syscall
		
		lw $t0, ($s5)
		addi $t0, $t0, 1
		sw $t0, ($s5)		# numMisses[player]++
		
		nor $s1, $s1, $s1	#player = !player
		li $s4, 0			# isHit = 0
		
	
	afterMiss:
	
	move $a0, $s2			#Prints the opponents board
	syscall
	
	jr $ra

#
#	This functions plays a sound when a hit occurs
#
#	input -> none
#
#	output -> none
playHitSound:
	li $v0, 31		## synchronous sounds
	li $a2, 43 	## load in strings
	li $a3, 127	## vol = max
	
	## This sound sounds nice so It's the sound to make when a ship is hit
	li $a0 70		## pitch: A Sharp
	li $a1, 500	## duration(ms)
	syscall
	
	li $a0 62		## pitch: D
	li $a1, 500	## duration(ms)
	syscall
	
	jr $ra
	
#
#	This functions plays a sound when a miss occurs
#
#	input -> none
#
#	output -> none	

playMissSound:
	li $v0, 31		## synchronous sounds
	li $a2, 43 	## load in strings
	li $a3, 127	## vol = max
	
	## this sound sounds ugly so it's the sound when you miss a ship
	li $a0 61		## pitch: C sharp
	li $a1, 500	## duration(ms)
	syscall
	
	li $a0 47		## pitch: LOW C
	li $a1, 500	## duration(ms)
	syscall
	
	jr $ra

loadMissMessage:		## loads address of the space into $t2
	la $t2, MissMessage
	li $t3, 77 #M
	sb $t3, 0($t2)
	
	li $t3, 73 #I
	sb $t3, 1($t2)
	
	li $t3, 83 #S
	sb $t3, 2($t2)
	
			#S
	sb $t3, 3($t2)
	
	li $t3, 33 #!
	sb $t3, 4($t2)
	
	li $t3, 32 #SPACE
	sb $t3, 5($t2)
	
	li $t3, 64 #@
	sb $t3, 6($t2)
	
	li $t3, 32 #SPACE
	sb $t3, 7($t2)
	
	li $t3, 67 #C
	sb $t3, 8($t2)
	
	li $t3, 79 #
	sb $t3, 9($t2)	#O
	sb $t3, 10($t2)	#O
	
	li $t3, 82 #R
	sb $t3, 11($t2)
	
	li $t3, 68 #D
	sb $t3, 12($t2)
	
	li $t3, 32 #SPACE
	sb $t3, 13($t2)
	
	li $t3, 40 #(
	sb $t3, 14($t2)
	
	####	THIS LINE STORES THE INPUT ROW INTO THE STRING
	loadAskRow01:	bnez $t0, loadAskRow11		#if( askRow == 0
		li $t3, 48#0
		sb $t3, 15($t2)
		j afterAskRow1
			
	loadAskRow11:	bne  $t0, 1, loadAskRow21
		li $t3, 49#1
		sb $t3, 15($t2)
		j afterAskRow1
		
	loadAskRow21:	bne  $t0, 2, loadAskRow31
		li $t3, 50#2
		sb $t3, 15($t2)
		j afterAskRow1
		
	loadAskRow31: bne  $t0, 3, loadAskRow41
		li $t3, 51#3
		sb $t3, 15($t2)
		j afterAskRow1
		
	loadAskRow41:
		li $t3, 52#4
		sb $t3, 15($t2)
		
		
	afterAskRow1:
	li $t3, 44 #,
	sb $t3, 16($t2)
	
			
	li $t3, 32 #SPACE
	sb $t3, 17($t2)
	
	####	THIS LINE STORES THE ASK COL
	loadAskCol01:	bnez $t1, loadAskCol11		#if( askCol == 0 )
		li $t3, 48#0
		sb $t3, 18($t2)
		j afterAskCol1
			
	loadAskCol11:		bne  $t1, 1, loadAskCol21
		li $t3, 49#1
		sb $t3, 18($t2)
		j afterAskCol1
		
	loadAskCol21: 	bne  $t1, 2, loadAskCol31
		li $t3, 50#2
		sb $t3, 18($t2)
		j afterAskCol1
		
	loadAskCol31:		bne  $t1, 3, loadAskCol41
		li $t3, 51#3
		sb $t3, 18($t2)
		j afterAskCol1
		
	loadAskCol41:		
		li $t3, 52#4
		sb $t3, 18($t2)
		
		
	afterAskCol1:
	
	li $t3, 41 #)
	sb $t3, 19($t2)
	
	jr $ra

loadHitMessage:		## loads address of the space into $t2
	la $t2, HitMessage
	li $t3, 72 #H
	sb $t3, 0($t2)
	
	li $t3, 73 #I
	sb $t3, 1($t2)
	
	li $t3, 84 #T
	sb $t3, 2($t2)
	
	li $t3, 33 #!
	sb $t3, 3($t2)
	
	li $t3, 32 #SPACE
	sb $t3, 4($t2)
	
	li $t3, 64 #@
	sb $t3, 5($t2)
	
	li $t3, 32 #SPACE
	sb $t3, 6($t2)
	
	li $t3, 67 #C
	sb $t3, 7($t2)
	
	li $t3, 79 #
	sb $t3, 8($t2)	#O
	sb $t3, 9($t2)	#O
	
	li $t3, 82 #R
	sb $t3, 10($t2)
	
	li $t3, 68 #D
	sb $t3, 11($t2)
	
	li $t3, 32 #SPACE
	sb $t3, 12($t2)
	
	li $t3, 40 #(
	sb $t3, 13($t2)
	
	####	THIS LINE STORES THE INPUT ROW INTO THE STRING
	loadAskRow0:	bnez $t0, loadAskRow1		#if( askRow == 0
		li $t3, 48#0
		sb $t3, 14($t2)
		j afterAskRow
			
	loadAskRow1:	bne  $t0, 1, loadAskRow2
		li $t3, 49#1
		sb $t3, 14($t2)
		j afterAskRow
		
	loadAskRow2: bne $t0, 2, loadAskRow3
		li $t3, 50#2
		sb $t3, 14($t2)
		j afterAskRow
		
	loadAskRow3: bne $t0, 3, loadAskRow4
		li $t3, 51#3
		sb $t3, 14($t2)
		j afterAskRow
		
	loadAskRow4: 
		li $t3, 52#4
		sb $t3, 14($t2)
		
		
		
	afterAskRow:
	li $t3, 44 #,
	sb $t3, 15($t2)
	
			
	li $t3, 32 #SPACE
	sb $t3, 16($t2)
	
	####	THIS LINE STORES THE ASK COL
	loadAskCol0:	bnez $t1, loadAskCol1		#if( askCol == 0 )
		li $t3, 48#0
		sb $t3, 17($t2)
		j afterAskCol
			
	loadAskCol1:	bne  $t1, 1, loadAskCol2
		li $t3, 49#1
		sb $t3, 17($t2)
		j afterAskCol
		
	loadAskCol2: bne $t1, 2, loadAskCol3
		li $t3, 50#2
		sb $t3, 17($t2)
		j afterAskCol
	
	loadAskCol3: bne $t1, 3, loadAskCol4
		li $t3, 51#3
		sb $t3, 17($t2)
		j afterAskCol
		
	loadAskCol4:
		li $t3, 52#4
		sb $t3, 17($t2)
		
		
	afterAskCol:
	
	li $t3, 41 #)
	sb $t3, 18($t2)
	
	jr $ra

#
#	This function displays the opening message
#	initializes the gameboard, and determines the beginning player
#
#	inputs : none
#
#	outputs: $s1 -> player who starts the game
initializeGame:	
			sw $ra, -4($sp)
			jal openingMessage		#Prints the opening message to the screen		
			lw $ra, -4($sp)
			  
	
			li $s1, 1				# $s1 keeps track of the player (sets player to player 1)
			la $s0, playerTwoViewBoard
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal initializeBoard			#Initalizes an empty gameBoard accepts 2x2 parameter in $s0
			lw $ra, 0($sp)
			addi $sp, $sp, 4  
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			la $s0, playerOneBoard
			jal initializeBoard			
			lw $ra, 0($sp)
			addi $sp, $sp, 4  
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal placeShips			#Gets 3 coordinates from the user and inputs them in the user's gameboard
			lw $ra, 0($sp)
			addi $sp, $sp, 4  
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal printBoard			#Prints the gameboard to and output dialog. Array printed stored in $s0
			lw $ra, 0($sp)
			addi $sp, $sp, 4  
	
			li $s1, 0				#keeps track of the player (sets player to player 2)
			la $s0, playerOneViewBoard
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal initializeBoard			#Initalizes an empty gameBoard accepts 2x2 parameter in $s0
			lw $ra, 0($sp)
			addi $sp, $sp, 4  
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			la $s0, playerTwoBoard
			jal initializeBoard
			lw $ra, 0($sp)
			addi $sp, $sp, 4  
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal placeShips			#Gets 3 coordinates from the user and inputs them in the user's gameboard
			lw $ra, 0($sp)
			addi $sp, $sp, 4  
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal printBoard			#Prints the gameboard to and output dialog. Array printed stored in $s0
			lw $ra, 0($sp)
			addi $sp, $sp, 4  
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal randNum			#Prints the gameboard to and output dialog. Array printed stored in $s0
			lw $ra, 0($sp)
			addi $sp, $sp, 4  
			
			jr $ra


#
#	This function iterates through a 4 bit LFSR to choose the player
#	This function was created by Hannah Moein 
#
#	inputs: none
#
#	outputs: $s1 player (returns 0 or 1)
#	
randNum:	
	
	li $v0, 51	
	la $a0, enterSeed	
	syscall
	move $t4, $a0
	addi $t3, $t3, 0	#i == 0
	li $s1, 2	#seed is 0010
	whileRandNum: bge $t3, $t4, exitRandNum		#while ( i < seed )
	
		move $t0, $s1
		move $t1, $s1 
					  
		andi $t0, $t0, 1	### x1 
	
		srl $t1, $t1, 1
		andi $t1, $t1, 1 ### x2

		xor $t2, $t1, $t0 #### y = X2 xor X1

		bnez $t2, else

		### y ==0 
		srl $s1, $s1 , 1 ### 0 X4 X3 X2 : final number
		addi $t3, $t3, 1	# i++
		j whileRandNum

	else:
				###y ==1 
		srl $s1, $s1, 1 	### X >> 1 :  0 X4 X3 X2
		sll $t2,$t2, 3 	### Y << 3:  	Y 0  0  0
		or $s1, $t2, $s1 	### Xnew :    Y X4 X3 X2 final number
		
		addi $t3, $t3, 1	# i++
		j whileRandNum

		
	exitRandNum:
	
		li $t0, 2
		divu $s1, $t0		# $s1 mod $t0 returns val into HI
		mfhi $s1			# LFSR mod 2
		
	printPlayerThatGoesFirst:
		la $s0, playerXGoesFirst
		
		bnez $s1 choosePlayerTwo	#if ($s1 == 0)
			
			li $t6, 49	#1
			sb $t6, 7($s0)
			li $v0, 55
			move $a0, $s0
			li $a1, 1
			syscall
			
			la $s0, playerTwoBoard
			la $s2, playerOneViewBoard
			
		j afterChoosePlayer
		
		choosePlayerTwo:
			li $t6, 50	#2
			sb $t6, 7($s0)
			li $v0, 55
			move $a0, $s0
			li $a1, 1
			syscall
			
			la $s0, playerOneBoard
			la $s2, playerTwoViewBoard
		afterChoosePlayer:
												
		jr $ra 


#
#	This function iterates 3 times to find place the 3 ships
#	Offset of the player's array is 19 to account for 
#	"PLAYER X'S BOARD\n["	
#
#	inputs: $s0 -> the board for the ships to be placed on
#
#	outputs: none
placeShips: 
		
		li $t6, 83			# t6 = 'S'
		li $v0, 51			#Get integer from user stored in $a0 
		li $a1, 1
		addi $t3, $zero, 0		#i = 0
		
		whileShips: bge $t3, 5, endPlaceShips#t3 = i --> while (i < 5)
			addi $t0, $0, 0
			addi $t1, $0, 0
			
			la $a0, askRow		# scanf("%d", &row)
			syscall		
			move $t0, $a0
		
			la $a0, askCol			# scanf("%d", &col)
			syscall
			move $t1, $a0	
		
			mul $t0, $t0, 21		# row*12
			mul $t1, $t1, 4 		# col*4
			add $t0, $t1, $t0 		# row*12 + col*4
			addi $t0, $t0, 18 		# OFFSET = row*12 + col*4 + 18 * you add 18 to offset "PLAYER X'S BOARD\n[" *
			

			add $t2, $s0, $t0 		# t2 gets address of board array + offset
			sb $t6, ($t2)
			
			addi $t3, $t3, 1		# i++
			j whileShips
		endPlaceShips:
			jr $ra
	
#
#	Function desctiption: function prints the array to the screen
#
#	inputs: $s0 -> gameboard
#	
#	outputs: none
printBoard:	
		
		li $v0, 55
		li $a1, 1
		move $a0, $s0
		syscall
		jr $ra
			
#
#	Function description: this function initializes the gameboard array
#
#	inputs: $s0 -> gameBoard
#	
#	outputs: none
initializeBoard:	 
			li $t0, 91	#[
			li $t1, 93 	#]
			li $t2, 32 	#W(Changed to space)
			lb $t3, newLine #\n
			#li $t3, 13	#\n
			li $t4, 32	#[SPACE]
			li $t5, 0	#[NULL]
			
				
				li $t6,  80 #P
				sb $t6, 0($s0)
				
				li $t6,  76 #L
				sb $t6, 1($s0)
				
				li $t6,  65 #A
				sb $t6, 2($s0)
				
				li $t6,  89 #Y
				sb $t6, 3($s0)
				
				li $t6,  69 #E
				sb $t6, 4($s0)
				
				li $t6, 82 #R
				sb $t6, 5($s0)
				
				li $t6, 32 #SPACE
				sb $t6, 6($s0)
				
				bnez $s1 makePlayerOneBoard	#if ($s1 == 0)
					li $t6, 50	#2
					sb $t6, 7($s0)
					j afterMakeBoard
				
					makePlayerOneBoard:
						li $t6, 49	#1
						sb $t6, 7($s0)

				afterMakeBoard:
				
				li $t6, 39	#'
				sb $t6, 8($s0)
				
				li $t6, 83	#S
				sb $t6, 9($s0)
				
				li $t6, 32	#SPACE
				sb $t6, 10($s0)
				
				li $t6, 66	#B
				sb $t6, 11($s0)
				
				li $t6, 79	#O
				sb $t6, 12($s0)
				
				li $t6, 65	#A
				sb $t6, 13($s0)
				
				li $t6, 82	#R
				sb $t6, 14($s0)
				
				li $t6, 68	#D
				sb $t6, 15($s0)
				
				sb  $t3, 16($s0)	#\n
				
				addi $s0, $s0, 17 #updates the address of array
				li $t8, 0	#i = 0
				
				buildRow: 	bge $t8, 5, termBuildRow#while(i < 3)
													
						sb  $t0, 0($s0)	#[W] 
						sb  $t2, 1($s0)
						sb  $t1, 2($s0)							
						sb  $t4, 3($s0)
										
						sb  $t0, 4($s0)	#[W]
						sb  $t2, 5($s0)
						sb  $t1, 6($s0)							
						sb  $t4, 7($s0)
						
						sb  $t0, 8($s0)	#[W]
						sb  $t2, 9($s0)
						sb  $t1, 10($s0)							
						sb  $t4, 11($s0)
						
						sb  $t0, 12($s0)	#[W]
						sb  $t2, 13($s0)
						sb  $t1, 14($s0)							
						sb  $t4, 15($s0)
				
						sb  $t0, 16($s0)	#[W]\n
						sb  $t2, 17($s0)
						sb  $t1, 18($s0)
						sb  $t4, 19($s0)
						sb  $t3, 20($s0)	
						
						addi $t8, $t8, 1	#++i
						addi $s0, $s0, 21 #updates the memory address
						j buildRow
						
				termBuildRow:
					addi $s0, $s0, -122 #This line puts s0 back at its original memory address
					jr $ra

end:
	li $v0, 10
	syscall

openingMessage:
	li $v0, 55
	la $a0, welcome
	li $a1, 1
	syscall
	
	jr $ra
