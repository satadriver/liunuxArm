	
	
MEM_LOAD_BASE		EQU 0X40000000
PAGE_TABLE_ENTRY	EQU (MEM_LOAD_BASE + 0X1000)

VIRTUAL_MEM_BASE 	EQU 0XC0000000
	
	export __initMemoryProc
	
	

	
	
	
	PRESERVE8 
	AREA CODE, CODE, READONLY

	
__initMemoryProc

	;import resetHandlerC
	;bl resetHandlerC
	
	stmfd sp!,{r0-r3,r14}
	
	ldr r0,=PAGE_TABLE_ENTRY
	LDR R1,=VIRTUAL_MEM_BASE
	ORR R1,R1,#0X12
	STR R1,[R0]
	
	
	
	ldr r0,=PAGE_TABLE_ENTRY
	;use p15 but not P15,use lowercase
	MCR p15,0,R0,c2,c0,0
	MVN R0,#0
	MCR p15,0,r0,c3,c0,0
	MOV R0,#1
	MCR p15,0,r0,c1,c0,0
	
	LDR R1,=VIRTUAL_MEM_BASE
	MOV R0,#0XFF
	STR R0,[R1]
	
	ldmfd sp!,{r0-r3,pc}
	
	END