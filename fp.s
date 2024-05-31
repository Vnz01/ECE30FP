//////////////////////////
//			//
// Project Submission	//
//			//
//////////////////////////

// Partner 1: Venz Burgos, A16230301
// Partner 2: Giovanni Clark, A17954052

//////////////////////////
//			//
//	main		//
//                    	//
//////////////////////////

main:	lda x4, symbol
	ldur x0, [x4, #0]
	bl FindTail
	addi x2, x1, #24
	stur x2, [sp, #0]
	bl Partition
	ldur x0, [sp, #0]
	lda x5, encode
	ldur x1, [x5, #0]
CheckSymbol:
	ldur x2, [x1, #0]
	subs xzr, x2, xzr
	b.ge KeepEncode
	stop

KeepEncode:
	stur x1, [sp, #0]
	bl Encode
	ldur x1, [sp, #0]
	addi x1, x1, #8
	b CheckSymbol

	
////////////////////////
//                    //
//   FindTail         //
//                    //
////////////////////////
FindTail:
	// input:
	// x0: address of (pointer to) the first symbol of symbol array
	// output:
	// x1: address of (pointer to) the first symbol of symbol array

	// allocate stack 32 bytes, parent FP at 0, link register at 8, x0 at 16
	subi	sp, sp, #32
	stur	fp, [sp, #0]
	addi	fp, sp, #24
	stur	lr, [sp, #8]
	stur	x0, [sp, #16]

	ldur	x2, [x0, #16] // load x2 with the next value
	addi	x3,	x2, #1 // check if the next value + 1 is 0
	cbz		x3, returnFindTail // if 0 that means we are ath the end so branch to done
	addi	x0,	x0, #16 // else move to next array element
	bl		FindTail // branch to find tail

	b		doneFindTail

	returnFindTail:
	// can also use mov, but this just sets x1 to have the address of x0
	add		x1, x0, xzr

	doneFindTail:
	// load the old parent register values and delete stack
	ldur	fp, [sp, #0]
	ldur	lr, [sp, #8]
	ldur	x0, [sp, #16]
	addi	sp, sp, #32	

	br lr


////////////////////////
//                    //
//   FindMidpoint     //
//                    //
////////////////////////
FindMidpoint:
	// input:
	// x0: address of (pointer to) the first symbol of the symbol array
	// x1: address of (pointer to) the last symbol of the symbol array
	// x2: sum of the frequency of the left sub-array
	// x3: sum of the frequency of the right sub-array
	
	// output:
	// x4: address of (pointer to) the first element of the right-hand side sub-array

	subi	sp, sp, #48
	stur	fp, [sp, #0]
	addi	fp, sp, #40
	stur	lr, [sp, #8]
	stur	x0, [sp, #16]
	stur	x1, [sp, #24]
	stur	x2, [sp, #32]
	stur	x3, [sp, #40]

	// Check if head + 2 == tail, implementation 1
	addi	x5, x0, #16 // set x5 = head + 2
	subs	xzr, x5, x1 // set flag for address of x5 - x1
	b.eq	returnFindMidpoint

	// // Check if head + 2 == tail, implementation 2
	// ldur	x5, [x0, #16] // load head + 2 into x5
	// ldur	x6, [x1, #0] // load tail into x6
	// subs	xzr, x5, x6 // set flag for values x5 - x6
	// b.eq	returnFindMidpoint

	subs	xzr, x2, x3
	b.le	ifFindMidpoint

	subi	x1, x1, #16 // move tail - 2
	ldur	x7, [x1, #8] // load tail + 1 which is the freq
	add		x3,	x3, x7 // add to right sum

	b		recurMidpoint // recurison

	ifFindMidpoint:
	addi	x0, x0, #16 // move head + 2
	ldur	x8, [x0, #8] // load head + 1 which is the freq
	add		x2,	x2, x8	// add into left sum the freq of symbol

	recurMidpoint: 
	bl		FindMidpoint

	b		doneFindMidpoint // go straight to done

	returnFindMidpoint: // give x4 the address of the first value of the right side
	add		x4, x1, xzr

	doneFindMidpoint:
	ldur	fp, [sp, #0]
	ldur	lr, [sp, #8]
	ldur	x0, [sp, #16]
	ldur	x1, [sp, #24]
	ldur	x2, [sp, #32]
	ldur	x3, [sp, #40]
	addi	sp, sp, #48	

	br lr


////////////////////////
//                    //
//   Partition        //
//                    //
////////////////////////
Partition:
	// input:
	// x0: address of (pointer to) the first symbol of the symbol array
	// x1: address of (pointer to) the last symbol of the symbol array
	// x2: address of the first attribute of the current binary tree node

	// start = x9
	// end = x10
	// midpoint = x11
	// offset = x12
	// left_node and right_node = x13

	// Allocate space for x0, x1, x2, lr, and fp
	subi sp, sp, #48
	stur fp, [sp, #0]
	addi fp, sp, #40
	stur lr, [sp, #8]
	stur x0, [sp, #16]
	stur x1, [sp, #24]
	stur x2, [sp, #32]

	// Store start pointer in node and end pointer in node+1
	stur x0, [x2, #0]
	stur x1, [x2, #8]

	// Load start pointer in node and end pointer in node+1 to new registers 
	ldur x9, [x2, #0]
	ldur x10, [x2, #8]

	subs xzr, x9, x10               // Compare x9 (start) and x10 (end)
	b.ne elsePartition              // If start != end, branch to elsePartition
	subi x11, xzr, #1               // Temporarily set x11 to NULL
	stur x11, [x2, #16]             // Store NULL in node+2 (left_node)
	stur x11, [x2, #24]             // Store NULL in node+3 (right_node)
	b donePartition

	elsePartition:
		ldur x2, [x0, #8]           // Load value stored in start+1 to x2 (left_sum) 
		ldur x3, [x1, #8]           // Load value stored in end+1 to x3 (right_sum)
		bl FindMidpoint             // Branch to FindMidpoint
		add x11, xzr, x4			// Load result of FindMidpoint to temporary register x11 (midpoint)
		stur x11, [sp, #40]         // Store midpoint in the stack
		ldur x2, [sp, #32]          // Restore original value in x2

		// Offset setup
		sub x12, x11, x9            // Offset (x12) = midpoint (x11) - start (x9)
		subi x12, x12, #8           // Offset (x12) = offset - 1

		//Left_node setup
		addi x13, x2, #32           // Left_node (x13) = node + 4
		stur x13, [x2, #16]         // Store left_node in node+2

		// Right_node setup
		lsl x13, x12, #2            // Right_node (x13) = offset (x12) * 4 = offset * 2^2
		addi x13, x13, #32          // Right_node (x13) = offset (x12) + (4*8)
		add x13, x13, x2            // Add node address to to the right_node (x13)
		stur x13, [x2, #24]         // Store result (right_node) in node+3

		// Call Partition(start, midpoint - 2, left_node)
		ldur x0, [sp, #16]          // Load current start
		subi x11, x11, #16          // Midpoint = midpoint - 2
		add x1, xzr, x11            // Make x1 (end) equal to midpoint - 2
		ldur x2, [sp, #32]          // Load left_node to x2 (node)
		ldur x2, [x2, #16]          // Node = node+2 (left_node)
		bl Partition                // Branch to Partition

		// Call Partition(midpoint, end, right_node)
		ldur x11, [sp, #40]         // Restore midpoint to original value
		add x0, xzr, x11            // Set x0 (start) equal to midpoint (x11)
		ldur x1, [sp, #24]          // Load current end
		ldur x2, [sp, #32]          // Load current node to x2 (node)
		ldur x2, [x2, #24]			// Node = node+3 (right_node)
		bl Partition                // Branch to Partition

	donePartition:
		// Load old parent register values and delete stack 
		ldur fp, [sp, #0]
		ldur lr, [sp, #8]
		ldur x0, [sp, #16]
		ldur x1, [sp, #24]
		ldur x2, [sp, #32]
		addi sp, sp, #48

    	br lr

	
////////////////////////
//                    //
//   IsContain        //
//                    //
////////////////////////
IsContain:
	// input:
	// x0: address of (pointer to) the first symbol of the sub-array
	// x1: address of (pointer to) the last symbol of the sub-array
	// x2: symbol to look for

	// output:
	// x3: 1 if symbol is found, 0 otherwise


	ldur	x4, [x0, #0] // load the first symbol into X4
	ldur 	x5,	[x1, #0] // load the last symbol into X5

	subs	xzr, x4, x5	// check if first symbol greater than last symbol (ERROR CHECKING)
	b.gt	returnIsntContain // return 0

	loop: // start loop

	ldur	x4, [x0, #0] // update x4
	subs	xzr, x4, x2 // check if the symbol is equal to the symbol we looking for X2
	b.eq	returnIsContain // if equal return 1

	addi	x0,	x0,	#16 // head = head + 2

	subs	xzr, x4, x5 // set flags for x4 compared to x5
	b.lt	loop // if less than or equal continue the loop

	returnIsntContain: // set x3 to 0 
	addi	x3,	xzr, #0
	b		doneIsContain // then branch to done

	returnIsContain: // set x3 to 1
	addi	x3, xzr, #1 // then continue

	doneIsContain:
	br lr


////////////////////////
//                    //
//   Encode           //
//                    //
////////////////////////
Encode:	
	// input:
	// x0: the address of (pointer to) the binary tree node 
	// x2: symbols to encode

	// Allocate space in the frame for fp, lr, x0, and x2
	subi sp, sp, #32
	stur fp, [sp #0]
	addi fp, fp, #24
	stur lr, [sp, #8]
	stur x0, [sp, #16]
	stur x2, [sp, #24]

	// Load value in node+2 to x9 (left_node)
	ldur x9, [x0, #16]
	// Load value in node+3 to x10 (right_node)
	ldur x10, [x0, #24]

	subs xzr, x9, x10		// Compare x9 and x10
	b.eq doneEncode 		// If x9 == x10, branch to doneEncode

	// Calling IsContain(*left_node, *(left_node+1), symbol)
	ldur x0, [x9, #0] 		// x0 = *left_node
	ldur x1, [x9, #8] 		// x1 = *(left_node+1)
	bl IsContain 			// Branch to IsContain function

	subis xzr, x3, #1 		// Compare x3 (IsContain output) to 1
	b.ne elseEncode 		// If != 1, branch to elseEncode
	putint xzr 				// Print 0

	// Calling Encode(left_node, symbol)
	add x0, xzr, x9 		// x0 = left_node (x9)
	bl Encode 				// Branch to Encode
	b doneEncode 			// Branch to doneEncode

	elseEncode:
		addi x11, xzr, #1 	// x11 = 1
		putint x11 			// Print 1 (x11)

		// Calling Encode(right_node, symbol)
		add x0, xzr, x10 	// x0 = right_node (x10)
		bl Encode 			// Branch to Encode

	doneEncode:
		// Load old parent register values and delete stack
		ldur fp, [sp, #0]
		ldur lr, [sp, #8]
		ldur x0, [sp, #16]
		ldur x2, [sp, #24]
		addi sp, sp #32

	br lr