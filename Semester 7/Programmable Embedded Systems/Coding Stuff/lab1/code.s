	AREA main, CODE, READONLY ;
	EXPORT __main
	ENTRY
__main
	mov R0, #90
	mov R1, #7
gcd cmp R0, R1
	subgt R0, R0, R1
	sublt R1, R1, R0
	bne gcd