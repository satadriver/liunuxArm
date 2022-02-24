
extern void resetHandlerC(void);







#define USER_MODE 		0X10
#define FIQ_MODE 			0X11
#define INT_MODE 			0X12
#define SERVICE_MODE 	0X13
#define ABT_MODE 			0X17
#define UNDEFINE_MODE 0X1B
#define SYSTEM_MODE 	0X1F


#pragma pack(1)
typedef struct
{
	unsigned int reset;
	unsigned int undef;
	unsigned int swi;
	unsigned int pabt;
	unsigned int dabt;
	unsigned int reserved;
	unsigned int irq;
	unsigned int fiq;
}INT_VECTORS;
#pragma pack()

void boot_init(void);
void resetHandlerC(void);
void initInterruptions(void);


typedef void (*InitSystemFuncArray)(void);

void resetHandlerC(void)
{
	boot_init();
}

void initInterruptions(void)
{
	return;
}

static InitSystemFuncArray gInitFunArray[]={
	initInterruptions,
	0
};	


void boot_init(void){
	int i = 0;
	for(i = 0;gInitFunArray[i];i++){
		gInitFunArray[i]();
	}
}





