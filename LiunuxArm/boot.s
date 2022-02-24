
	
	
	
USER_MODE 		equ 0X10
FIQ_MODE 		equ 0X11
IRQ_MODE 		equ 0X12
SERVICE_MODE 	equ 0X13
ABT_MODE 		equ 0X17
UNDEFINE_MODE 	equ 0X1B
SYSTEM_MODE 	equ 0X1F
	

	


	
	PRESERVE8 
	AREA CODE, CODE, READONLY
	
	ENTRY 	;ENTRY is not nessesary
	ARM

	LDR pc,resetAddr

	ldr pc,undefAddr
		
	ldr pc,swiAddr
		
	ldr pc,pabtAddr
		
	ldr pc,dabtAddr
		
	nop
		
	ldr pc,irqAddr
		
	;ldr pc,[pc,#-0xff0]
		
	ldr pc,fiqAddr
	
resetAddr 	DCD resetHandler
undefAddr	DCD undefHandler
swiAddr		DCD	swiHandler
pabtAddr	DCD	pabtHandler
dabtAddr	DCD	dabtHandler
			DCD 0
irqAddr		DCD	irqHandler
fiqAddr		DCD	fiqHandler




;BOOT_STACK_SIZE EQU 0X100

MEM_LOAD_BASE		EQU 0X40000000
tmpUserStackBase 	equ (0x0000000 + MEM_LOAD_BASE)
tmpUserStackEnd		equ (0x00001000 + MEM_LOAD_BASE)
tmpSystemStackBase 	equ (0x00001100 + MEM_LOAD_BASE)
tmpSystemStackEnd	equ (0x00001200 + MEM_LOAD_BASE)
undefStackBase 		equ (0x00001200 + MEM_LOAD_BASE)
undefStackEnd		equ (0x00001300 + MEM_LOAD_BASE)
svcStackBase		equ (0x00001300 + MEM_LOAD_BASE)
svcStackEnd			equ (0x00001400 + MEM_LOAD_BASE)
abtStackBase 		equ (0x00001400 + MEM_LOAD_BASE)
abtStackEnd			equ (0x00001500 + MEM_LOAD_BASE)
irqStackBase 		equ (0x00001500 + MEM_LOAD_BASE)
irqStackEnd			equ (0x00001600 + MEM_LOAD_BASE)
fiqStackBase 		equ (0x00001600 + MEM_LOAD_BASE)
fiqStackEnd			equ (0x00001700 + MEM_LOAD_BASE)

PAGE_TABLE_ENTRY	EQU (MEM_LOAD_BASE + 0X2000)

	extern __uartInit
	extern __uartSend
	extern __uartRecv
	extern __initInterruptionProc
	extern __initMemoryProc
	extern initMemory
	extern __enableInt
	extern __intHandler
	extern __unmaskInt
	
resetHandler 	
	
	;CSPR or PSPR
	;d31 N		negtive
	;d30 Z		zero
	;d29 C		carry
	;d28 V		overflow
	;d27 Q		float number overflow
	;d7 	I 1=disabled irq,0=enabled irq
	;d6 	F 1=disabled fiq,0=enabled fiq
	;d5 	T 1=enable thumb mode,0=disabled thumb mode
	;d0-d4 	mode,see define .c files
	


	mov r0,#FIQ_MODE
	msr cpsr_c,r0
	;ldr access label address range in 4gb,example:ldr r0,=0x12345678,but not ldr r0,=#0x12345678
	;adr access label address range in 255 or 1020 bytes
	;adrl access label address range in 64kb
	ldr r0,=fiqStackEnd
	mov sp,r0
	
	
	mov r0,#IRQ_MODE
	msr cpsr_c,r0
	ldr r0,=irqStackEnd
	mov sp,r0
	
	
	mov r0,#SERVICE_MODE
	msr cpsr_c,r0
	ldr r0,=svcStackEnd
	mov sp,r0
	
	
	mov r0,#ABT_MODE
	msr cpsr_c,r0
	ldr r0,=abtStackEnd
	mov sp,r0
	
	mov r0,#UNDEFINE_MODE
	msr cpsr_c,r0
	ldr r0,=undefStackEnd
	mov sp,r0
	
	mov r0,#SYSTEM_MODE
	msr cpsr_c,r0
	ldr r0,=tmpSystemStackEnd
	mov sp,r0
	
	;mov r0,#USER_MODE
	;msr cpsr_c,r0
	;ldr r0,=tmpUserStackEnd
	;mov sp,r0
	
	;swi #0x1000
	
	;bkpt #0x10

	extern resetHandlerC
	;ldr r0,=resetHandlerC
	;blx r0
	;bl resetHandlerC

	;bl initMemory
	
	
	BL __unmaskInt
	BL __enableInt

	bl __uartInit
	mov r0,#0x41
	bl __uartSend
	bl __uartRecv
	bl __uartRecv
	bl __uartRecv
	
	BL __initMemoryProc
_resetWaitLoop
	b _resetWaitLoop
	
	dcd 0xe1a00000
	nop
	
undefHandler
	stmfd sp!,{r0-r12,r14}
	extern undefHandlerC
	;ldr r0,=undefHandlerC
	;blx r0
	;bl undefHandlerC
	ldmfd sp!,{r0-r12,pc}^
	
swiHandler 
	stmfd sp!,{r0-r12,r14}
	ldr r0,[lr,#-4]
	bic r0,r0,#0xff000000
	
	extern swiHandlerC
	;bl swiHandlerC
	ldmfd sp!,{r0-r12,pc}^
	
pabtHandler 
	;sub lr,lr,#4
	;pabt return address in lr is next instruction after bkpt
	stmfd sp!,{r0-r12,r14}
	
	ldr r0,[lr,#-4]
	bic r0,r0,#0xffffff00
	
	extern pabtHandlerC
	;bl pabtHandlerC
	ldmfd sp!,{r0-r12,pc}^
	
dabtHandler 
	sub lr,lr,#8
	stmfd sp!,{r0-r12,r14}
	extern dabtHandlerC
	;bl dabtHandlerC
	ldmfd sp!,{r0-r12,pc}^
	
irqHandler 	
	sub lr,lr,#4
	stmfd sp!,{r0-r12,r14}
	extern irqHandlerC
	;bl irqHandlerC
	BL __intHandler
	ldmfd sp!,{r0-r12,pc}^
	
fiqHandler 
	sub lr,lr,#4
	stmfd sp!,{r0-r12,r14}
	extern fiqHandlerC
	;bl fiqHandlerC
	BL __intHandler
	ldmfd sp!,{r0-r12,pc}^

	;must be a TAB before END.else will be error
	;warning: A1447W: Missing END directive at end of file, but found a label named END
	END
	
	
	
		
	PRESERVE8 
	AREA DATA, DATA, READWRITE
	
	END		
		
		