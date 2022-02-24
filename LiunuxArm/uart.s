
UBRDIV0 	equ 0x56000028
GPHCON 		equ 0x56000070
ULCON0 		equ 0x56000000
GPH_MSK 	equ (15<<4)
GPH_URAT 	equ (10<<4)
UTXH0 		equ 0x56000020
URXH0 		equ 0x56000024

	export __uartInit
	export __uartSend
	export __uartRecv

	PRESERVE8 
	AREA CODE, CODE, READONLY
	
__uartInit
	stmfd sp!,{r0-r3,r14}

	ldr r0,=GPHCON
	ldr r1,[r0]
	and r1,r1,#0xf0
	orr r1,r1,#0xa0		;eor == xor orr = or
	str r1,[r0]
	
	ldr r0,=UBRDIV0
	mov r1,#0x1a
	str r1,[r0]
	
	ldr r0,=ULCON0
	mov r1,#0x3
	str r1,[r0]
	
	ldmfd sp!,{r0-r3,pc}
	

__uartSend
	stmfd sp!,{r0-r3,r14}

	ldr r1,=UTXH0
	str r0,[r1]
	
	ldmfd sp!,{r0-r3,pc}
	
	
__uartRecv
	stmfd sp!,{r0-r3,r14}

	ldr r1,=URXH0
	ldr r0,[r1]
	
	ldmfd sp!,{r0-r3,pc}
	END