main:	lda x4, symbol
	ldur x0, [x4, #0]
	bl FindTail
    ldur x20, [x1,#0]
    stop

	
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
	cbz		x3, return // if 0 that means we are ath the end so branch to done
	addi	x0,	x0, #16 // else move to next array element
	bl		FindTail // branch to find tail

	b		done

	return:
	// can also use mov, but this just sets x1 to have the address of x0
	add		x1, x0, xzr

	done:
	// load the old parent register values and delete stack
	ldur	fp, [sp, #0]
	ldur	lr, [sp, #8]
	ldur	x0, [sp, #16]
	addi	sp, sp, #32	

	br lr