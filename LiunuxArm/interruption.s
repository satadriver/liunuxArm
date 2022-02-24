	
	
	export __enableInt
	export __intHandler
	export __unmaskInt
	
INT_BASE 		EQU 0X4A000000
SRC_PND			EQU (INT_BASE + 0)
INT_MASK		EQU (INT_BASE + 8)
INT_PND			EQU (INT_BASE + 0X10)
INT_OFFSET 		EQU (INT_BASE + 0X14)

TCFG0 			EQU 0X51000000
TCFG1 			EQU 0X51000004
TCON 			EQU 0X51000008
TCNTB4 			EQU 0X5100003C



	PRESERVE8 
	AREA CODE, CODE, READONLY
	
__enableInt
	stmfd sp!,{r0-r3,r14}

	mrs r0,cpsr
	bic r0,r0,#0x80
	msr cpsr_C,r0
	
	ldmfd sp!,{r0-r3,pc}
	

__intHandler
	stmfd sp!,{r0-r3,r14}
	
	ldr r0,=INT_OFFSET
	ldr r1,[r0]
	mov r2,#1
	mov r2,r2,lsl r1	;lsl = asl; lsr != asr,asr keep magnificant bit; ror = rotate right roll
	
	ldr r0,=SRC_PND
	ldr r1,[r0]
	orr r1,r1,r2
	str r1,[r0]
	
	ldr r0,=INT_PND
	ldr r1,[r0]
	orr r1,r1,r2
	str r1,[r0]
	
	ldmfd sp!,{r0-r3,pc}

__unmaskInt
	stmfd sp!,{r0-r3,r14}
	
	ldr r0,=INT_MASK
	mov r1,#0
	str r1,[r0]
	
	ldmfd sp!,{r0-r3,pc}
	
__initTimer4


	END