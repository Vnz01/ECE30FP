//////////////////////////
//			//
// Project Submission	//
//			//
//////////////////////////

// Partner 1: Venz Burgos, A16230301
// Partner 2: (your name here), (Student ID here)

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

	loop:
	// load array[i] into x2
	ldur	x2, [x0, #0]
	// put into x3, value in x2 + 1
	addi	x3, x2, #1
	// if it is zero which means x2 or the address of x0 is at -1
	cbz		x3, end

	// move to next array value
	addi	x0, x0, #8
	b		loop

	done:
	// can also use mov, but this just sets x1 to have the address of x0
	add		x1, x0, xzr
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

	br lr
