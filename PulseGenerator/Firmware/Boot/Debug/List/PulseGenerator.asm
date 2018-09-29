
;CodeVisionAVR C Compiler V3.12 Advanced
;(C) Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Debug
;Chip type              : ATmega328P
;Program type           : Boot Loader
;Clock frequency        : 16.000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 512 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: Yes
;Enhanced function parameter passing: Yes
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega328P
	#pragma AVRPART MEMORY PROG_FLASH 32768
	#pragma AVRPART MEMORY EEPROM 1024
	#pragma AVRPART MEMORY INT_SRAM SIZE 2048
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU EECR=0x1F
	.EQU EEDR=0x20
	.EQU EEARL=0x21
	.EQU EEARH=0x22
	.EQU SPSR=0x2D
	.EQU SPDR=0x2E
	.EQU SMCR=0x33
	.EQU MCUSR=0x34
	.EQU MCUCR=0x35
	.EQU WDTCSR=0x60
	.EQU UCSR0A=0xC0
	.EQU UDR0=0xC6
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU GPIOR0=0x1E

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x08FF
	.EQU __DSTACK_SIZE=0x0200
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	PUSH R26
	PUSH R27
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	POP  R27
	POP  R26
	ICALL
	.ENDM

	.MACRO __CALL2EX
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __EEPROMRDD
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z
	MOVW R30,R0
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _hw_version=R4
	.DEF _get_status=R3
	.DEF _len=R6
	.DEF _isUpgrade=R5
	.DEF _tx_wr_index0=R8
	.DEF _tx_rd_index0=R7
	.DEF _tx_counter0=R10

;GPIOR0 INITIALIZATION VALUE
	.EQU __GPIOR0_INIT=0x00

	.CSEG
	.ORG 0x3800

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  _usart_rx_isr
	JMP  0x3800
	JMP  _usart_tx_isr
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800

_tbl10_G101:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G101:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x0,0x0,0x1,0x0
	.DB  0x0,0x0,0x0,0x0

_0x3:
	.DB  0x30,0x2E,0x30,0x2E,0x30

__GLOBAL_INI_TBL:
	.DW  0x08
	.DW  0x03
	.DW  __REG_VARS*2

	.DW  0x05
	.DW  _fw_version
	.DW  _0x3*2

_0xFFFFFFFF:
	.DW  0

#define __GLOBAL_INI_TBL_PRESENT 1

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF THE BOOT LOADER
	LDI  R31,1
	OUT  MCUCR,R31
	LDI  R31,2
	OUT  MCUCR,R31

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;GPIOR0 INITIALIZATION
	LDI  R30,__GPIOR0_INIT
	OUT  GPIOR0,R30

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x300

	.CSEG
;/*******************************************************
;This program was created by the
;CodeWizardAVR V3.12 Advanced
;Automatic Program Generator
;? Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;
;Project :
;Version :
;Date    : 8/8/2018
;Author  :
;Company :
;Comments:
;
;
;Chip type               : ATmega328P
;Program type            : Application
;AVR Core Clock frequency: 16.000000 MHz
;Memory model            : Small
;External RAM size       : 0
;Data Stack size         : 512
;*******************************************************/
;#include "main.h"
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif
;#include "system.h"
;#include "protocol.h"
;#include <iobits.h>
;
;// Declare your global variables here
;
;char hw_version = 0;
;char fw_version[] = "0.0.0";

	.DSEG
;
;serial_command_t request;
;serial_command_t respond;
;
;unsigned char get_status = GET_STATUS_COMPLETE;
;unsigned char len = 0;
;
;upgrade_page_request_t upgrade_page_request;
;
;bool isUpgrade = true;
;
;void main(void)
; 0000 002C {

	.CSEG
_main:
; .FSTART _main
; 0000 002D    // Declare your local variables here
; 0000 002E 
; 0000 002F    system_init();
	CALL _system_init
; 0000 0030 
; 0000 0031    // Global enable interrupts
; 0000 0032    #asm("sei")
	sei
; 0000 0033    while (1)
_0x4:
; 0000 0034    {
; 0000 0035       if(getCommand()){
	RCALL _getCommand
	CPI  R30,0
	BREQ _0x7
; 0000 0036          process_request();
	RCALL _process_request
; 0000 0037 
; 0000 0038          #asm("cli")
	cli
; 0000 0039          rx_counter0 = rx_wr_index0 = rx_rd_index0 = 0 ;
	CALL SUBOPT_0x0
; 0000 003A          #asm("sei")
	sei
; 0000 003B       }
; 0000 003C 
; 0000 003D       if(!isUpgrade){
_0x7:
	TST  R5
	BRNE _0x8
; 0000 003E             // Jump to application
; 0000 003F             #asm("cli")
	cli
; 0000 0040             #asm
; 0000 0041             LDI     R31, 0x00
            LDI     R31, 0x00
; 0000 0042             LDI     R30, 0x00
            LDI     R30, 0x00
; 0000 0043             IJMP               ;Jump to address 0x0000
            IJMP               ;Jump to address 0x0000
; 0000 0044             #endasm
; 0000 0045       }
; 0000 0046 
; 0000 0047    }
_0x8:
	RJMP _0x4
; 0000 0048 }
_0x9:
	RJMP _0x9
; .FEND
;
;bool getCommand(){
; 0000 004A _Bool getCommand(){
_getCommand:
; .FSTART _getCommand
; 0000 004B      // Place your code here
; 0000 004C       if(get_status == GET_STATUS_COMPLETE && rx_counter0 >= 7){
	TST  R3
	BRNE _0xB
	LDS  R26,_rx_counter0
	CPI  R26,LOW(0x7)
	BRSH _0xC
_0xB:
	RJMP _0xA
_0xC:
; 0000 004D          if(getchar() == 0xFF){
	CALL _getchar
	CPI  R30,LOW(0xFF)
	BRNE _0xD
; 0000 004E             if(getchar() == 0x55){
	CALL _getchar
	CPI  R30,LOW(0x55)
	BRNE _0xE
; 0000 004F                len = getchar();
	CALL _getchar
	MOV  R6,R30
; 0000 0050                if(len <= 135){
	LDI  R30,LOW(135)
	CP   R30,R6
	BRLO _0xF
; 0000 0051                   get_status = GET_STATUS_GETTING;
	LDI  R30,LOW(1)
	MOV  R3,R30
; 0000 0052 
; 0000 0053                }
; 0000 0054             }else{
_0xF:
	RJMP _0x10
_0xE:
; 0000 0055                #asm("cli")
	cli
; 0000 0056                 rx_counter0 = rx_wr_index0 = rx_rd_index0 = 0 ;
	CALL SUBOPT_0x0
; 0000 0057                #asm("sei")
	sei
; 0000 0058             }
_0x10:
; 0000 0059          }else{
	RJMP _0x11
_0xD:
; 0000 005A             #asm("cli")
	cli
; 0000 005B             rx_counter0 = rx_wr_index0 = rx_rd_index0 = 0 ;
	CALL SUBOPT_0x0
; 0000 005C             #asm("sei")
	sei
; 0000 005D          }
_0x11:
; 0000 005E       }
; 0000 005F 
; 0000 0060       if(get_status == GET_STATUS_GETTING){
_0xA:
	LDI  R30,LOW(1)
	CP   R30,R3
	BRNE _0x12
; 0000 0061          if(rx_counter0 >= len - 1){
	MOV  R30,R6
	LDI  R31,0
	SBIW R30,1
	LDS  R26,_rx_counter0
	LDI  R27,0
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x13
; 0000 0062             memcpy(&request, &rx_buffer0, len + 2);
	LDI  R30,LOW(_request)
	LDI  R31,HIGH(_request)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_rx_buffer0)
	LDI  R31,HIGH(_rx_buffer0)
	ST   -Y,R31
	ST   -Y,R30
	MOV  R30,R6
	LDI  R31,0
	ADIW R30,2
	MOVW R26,R30
	CALL _memcpy
; 0000 0063             get_status =  GET_STATUS_COMPLETE;
	CLR  R3
; 0000 0064 
; 0000 0065             return true;
	LDI  R30,LOW(1)
	RET
; 0000 0066          }
; 0000 0067       }
_0x13:
; 0000 0068 
; 0000 0069       return false;
_0x12:
	LDI  R30,LOW(0)
	RET
; 0000 006A }
; .FEND
;
;void process_request(){
; 0000 006C void process_request(){
_process_request:
; .FSTART _process_request
; 0000 006D    unsigned char len = request.len;
; 0000 006E 
; 0000 006F    if(checksum(&request.len, len) != 0){
	ST   -Y,R17
;	len -> R17
	__GETB1MN _request,2
	MOV  R17,R30
	__POINTW1MN _request,2
	ST   -Y,R31
	ST   -Y,R30
	MOV  R26,R17
	RCALL _checksum
	CPI  R30,0
	BREQ _0x14
; 0000 0070       response_error_checksum();
	RCALL _response_error_checksum
; 0000 0071    }else{
	RJMP _0x15
_0x14:
; 0000 0072       execute_cmd();
	RCALL _execute_cmd
; 0000 0073    }
_0x15:
; 0000 0074 }
	JMP  _0x2060002
; .FEND
;
;unsigned char checksum(unsigned char *dat, unsigned char len){
; 0000 0076 unsigned char checksum(unsigned char *dat, unsigned char len){
_checksum:
; .FSTART _checksum
; 0000 0077    unsigned char ck  = 0;
; 0000 0078    unsigned char i = 0;
; 0000 0079 
; 0000 007A    for(i = 0; i<len; i++){
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	*dat -> Y+3
;	len -> Y+2
;	ck -> R17
;	i -> R16
	LDI  R17,0
	LDI  R16,0
	LDI  R16,LOW(0)
_0x17:
	LDD  R30,Y+2
	CP   R16,R30
	BRSH _0x18
; 0000 007B       ck += *(dat + i);
	MOV  R30,R16
	LDI  R31,0
	LDD  R26,Y+3
	LDD  R27,Y+3+1
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	ADD  R17,R30
; 0000 007C    }
	SUBI R16,-1
	RJMP _0x17
_0x18:
; 0000 007D 
; 0000 007E    return ck;
	MOV  R30,R17
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,5
	RET
; 0000 007F }
; .FEND
;
;void response_error_checksum(){
; 0000 0081 void response_error_checksum(){
_response_error_checksum:
; .FSTART _response_error_checksum
; 0000 0082     unsigned char status = STATUS_ERROR_CHECKSUM;
; 0000 0083     send_respond((char *)&status, sizeof(status));
	ST   -Y,R17
;	status -> R17
	LDI  R17,2
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R18
	PUSH R17
	CALL SUBOPT_0x1
	POP  R17
	POP  R18
; 0000 0084 }
	JMP  _0x2060002
; .FEND
;
;void execute_cmd(){
; 0000 0086 void execute_cmd(){
_execute_cmd:
; .FSTART _execute_cmd
; 0000 0087     unsigned char status;
; 0000 0088     switch(request.opcode){
	ST   -Y,R17
;	status -> R17
	__GETB1MN _request,5
	LDI  R31,0
; 0000 0089     case CMD_READ_VERSION:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x1C
; 0000 008A         process_read_version();
	RCALL _process_read_version
; 0000 008B         break;
	RJMP _0x1B
; 0000 008C     case CMD_UPGRADE_START:
_0x1C:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x1D
; 0000 008D         process_upgrade_start();
	RCALL _process_upgrade_start
; 0000 008E         break;
	RJMP _0x1B
; 0000 008F     case CMD_UPGRADE_PAGE:
_0x1D:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x1E
; 0000 0090         process_upgrade_page();
	RCALL _process_upgrade_page
; 0000 0091         break;
	RJMP _0x1B
; 0000 0092     case CMD_UPGRADE_FINISH:
_0x1E:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x20
; 0000 0093         process_upgrade_finish();
	RCALL _process_upgrade_finish
; 0000 0094         break;
	RJMP _0x1B
; 0000 0095     default:
_0x20:
; 0000 0096         status = STATUS_UNSUPPORT;
	LDI  R17,LOW(3)
; 0000 0097         send_respond((char *)&status, sizeof(status));
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R18
	PUSH R17
	CALL SUBOPT_0x1
	POP  R17
	POP  R18
; 0000 0098         break;
; 0000 0099     }
_0x1B:
; 0000 009A }
	JMP  _0x2060002
; .FEND
;
;void process_upgrade_start(){
; 0000 009C void process_upgrade_start(){
_process_upgrade_start:
; .FSTART _process_upgrade_start
; 0000 009D     unsigned char status = STATUS_SUCCESS;
; 0000 009E     send_respond((char*)&status, sizeof(status));
	ST   -Y,R17
;	status -> R17
	LDI  R17,0
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R18
	PUSH R17
	CALL SUBOPT_0x1
	POP  R17
	POP  R18
; 0000 009F }
	JMP  _0x2060002
; .FEND
;
;void process_read_version(){
; 0000 00A1 void process_read_version(){
_process_read_version:
; .FSTART _process_read_version
; 0000 00A2     char *c;
; 0000 00A3     char str[] = "0.0.0";
; 0000 00A4     respond_read_version_t res;
; 0000 00A5     unsigned char hw0 = PIND.6;
; 0000 00A6     unsigned char hw1 = PIND.7;
; 0000 00A7     //hw_version = (hw1 << 1) | (hw0 << 0);
; 0000 00A8 
; 0000 00A9     res.status = STATUS_SUCCESS;
	SBIW R28,17
	LDI  R30,LOW(48)
	STD  Y+11,R30
	LDI  R30,LOW(46)
	STD  Y+12,R30
	LDI  R30,LOW(48)
	STD  Y+13,R30
	LDI  R30,LOW(46)
	STD  Y+14,R30
	LDI  R30,LOW(48)
	STD  Y+15,R30
	LDI  R30,LOW(0)
	STD  Y+16,R30
	CALL __SAVELOCR4
;	*c -> R16,R17
;	str -> Y+15
;	res -> Y+4
;	hw0 -> R19
;	hw1 -> R18
	LDI  R30,0
	SBIC 0x9,6
	LDI  R30,1
	MOV  R19,R30
	LDI  R30,0
	SBIC 0x9,7
	LDI  R30,1
	MOV  R18,R30
	LDI  R30,LOW(0)
	STD  Y+4,R30
; 0000 00AA     hw_version = hw1 * 2 + hw0 + 1;
	MOV  R30,R18
	LSL  R30
	ADD  R30,R19
	SUBI R30,-LOW(1)
	MOV  R4,R30
; 0000 00AB     strncpy(res.hw_version, str, 5);
	MOVW R30,R28
	ADIW R30,5
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,17
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(5)
	CALL _strncpy
; 0000 00AC     res.hw_version[0] = hw_version + 0x30;
	MOV  R30,R4
	SUBI R30,-LOW(48)
	STD  Y+5,R30
; 0000 00AD     strncpy(res.fw_version, fw_version, 5);
	MOVW R30,R28
	ADIW R30,10
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_fw_version)
	LDI  R31,HIGH(_fw_version)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(5)
	CALL _strncpy
; 0000 00AE     send_respond((char *)&res, sizeof(res));
	MOVW R30,R28
	ADIW R30,4
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(11)
	LDI  R27,0
	RCALL _send_respond
; 0000 00AF }
	CALL __LOADLOCR4
	ADIW R28,21
	RET
; .FEND
;
;void send_respond(char * payload, unsigned short len){
; 0000 00B1 void send_respond(char * payload, unsigned short len){
_send_respond:
; .FSTART _send_respond
; 0000 00B2     unsigned char i;
; 0000 00B3     unsigned char checksum = 0;
; 0000 00B4     unsigned char *c;
; 0000 00B5     respond.header = 0x55FF;
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	*payload -> Y+6
;	len -> Y+4
;	i -> R17
;	checksum -> R16
;	*c -> R18,R19
	LDI  R16,0
	LDI  R30,LOW(22015)
	LDI  R31,HIGH(22015)
	STS  _respond,R30
	STS  _respond+1,R31
; 0000 00B6     respond.len = 5 + len;
	LDD  R30,Y+4
	SUBI R30,-LOW(5)
	__PUTB1MN _respond,2
; 0000 00B7     respond.tranId = request.tranId;
	__GETB1MN _request,4
	__PUTB1MN _respond,4
; 0000 00B8     respond.opcode = request.opcode;
	__GETB1MN _request,5
	__PUTB1MN _respond,5
; 0000 00B9     respond.type = TYPE_RESPOND;
	LDI  R30,LOW(2)
	__PUTB1MN _respond,3
; 0000 00BA 
; 0000 00BB     memcpy(respond.payload, payload, len);
	__POINTW1MN _respond,6
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL _memcpy
; 0000 00BC 
; 0000 00BD     for(i = 0; i< respond.len - 1; i++){
	LDI  R17,LOW(0)
_0x22:
	__GETB1MN _respond,2
	LDI  R31,0
	SBIW R30,1
	MOV  R26,R17
	LDI  R27,0
	CP   R26,R30
	CPC  R27,R31
	BRGE _0x23
; 0000 00BE         checksum += *(&respond.len + i);
	__POINTW2MN _respond,2
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LD   R30,X
	ADD  R16,R30
; 0000 00BF     }
	SUBI R17,-1
	RJMP _0x22
_0x23:
; 0000 00C0 
; 0000 00C1     checksum = ~checksum + 1;
	NEG  R16
; 0000 00C2 
; 0000 00C3     c = (char*)&respond;
	__POINTWRM 18,19,_respond
; 0000 00C4     for(i = 0; i<respond.len + 2; i++){
	LDI  R17,LOW(0)
_0x25:
	__GETB1MN _respond,2
	LDI  R31,0
	ADIW R30,2
	MOV  R26,R17
	LDI  R27,0
	CP   R26,R30
	CPC  R27,R31
	BRGE _0x26
; 0000 00C5         putchar(c[i]);
	MOVW R26,R18
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LD   R26,X
	CALL _putchar
; 0000 00C6     }
	SUBI R17,-1
	RJMP _0x25
_0x26:
; 0000 00C7     putchar(checksum);
	MOV  R26,R16
	CALL _putchar
; 0000 00C8 }
	CALL __LOADLOCR4
	ADIW R28,8
	RET
; .FEND
;
;void process_upgrade_page()
; 0000 00CB {
_process_upgrade_page:
; .FSTART _process_upgrade_page
; 0000 00CC     unsigned char status = STATUS_SUCCESS;
; 0000 00CD     memcpy(&upgrade_page_request, request.payload, sizeof(upgrade_page_request));
	ST   -Y,R17
;	status -> R17
	LDI  R17,0
	LDI  R30,LOW(_upgrade_page_request)
	LDI  R31,HIGH(_upgrade_page_request)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1MN _request,6
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(129)
	LDI  R27,0
	CALL _memcpy
; 0000 00CE 
; 0000 00CF     #asm("cli")
	cli
; 0000 00D0 
; 0000 00D1     // Erase page
; 0000 00D2     boot_page_erase(upgrade_page_request.page);
	LDS  R26,_upgrade_page_request
	RCALL _boot_page_erase
; 0000 00D3 
; 0000 00D4     // Write page
; 0000 00D5     WritePage(upgrade_page_request.page_data, upgrade_page_request.page);
	__POINTW1MN _upgrade_page_request,1
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_upgrade_page_request
	CALL _WritePage
; 0000 00D6 
; 0000 00D7     #asm("sei")
	sei
; 0000 00D8 
; 0000 00D9     send_respond((char*)&status, sizeof(status));
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R18
	PUSH R17
	CALL SUBOPT_0x1
	POP  R17
	POP  R18
; 0000 00DA }
	JMP  _0x2060002
; .FEND
;
;void process_upgrade_finish()
; 0000 00DD {
_process_upgrade_finish:
; .FSTART _process_upgrade_finish
; 0000 00DE     // respond
; 0000 00DF     unsigned char status = STATUS_SUCCESS;
; 0000 00E0     send_respond((char*)&status, sizeof(status));
	ST   -Y,R17
;	status -> R17
	LDI  R17,0
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R18
	PUSH R17
	CALL SUBOPT_0x1
	POP  R17
	POP  R18
; 0000 00E1 
; 0000 00E2     delay_ms(10);
	LDI  R26,LOW(10)
	LDI  R27,0
	CALL _delay_ms
; 0000 00E3     isUpgrade = false;
	CLR  R5
; 0000 00E4 }
	JMP  _0x2060002
; .FEND
;
;/* Fill data into a temporary page (2 bytes once) */
;void boot_page_fill(unsigned int WordData, unsigned char Byte)
; 0000 00E8 {
_boot_page_fill:
; .FSTART _boot_page_fill
; 0000 00E9     //while (SPMEN);
; 0000 00EA     while(TSTBIT(SPMCSR,0));
	ST   -Y,R26
;	WordData -> Y+1
;	Byte -> Y+0
_0x27:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x27
; 0000 00EB #asm
; 0000 00EC     LDD     R1, Y+2     ;R1  <-- MSB of data (Byte N)
    LDD     R1, Y+2     ;R1  <-- MSB of data (Byte N)
; 0000 00ED     LDD     R0, Y+1     ;R0  <-- LSB of data (Byte N+1)
    LDD     R0, Y+1     ;R0  <-- LSB of data (Byte N+1)
; 0000 00EE     LDI     R31, 0x00   ;Load 0x00 into R31
    LDI     R31, 0x00   ;Load 0x00 into R31
; 0000 00EF     LDD     R30, Y+0    ;R30 <-- addr  (0-255 byte)
    LDD     R30, Y+0    ;R30 <-- addr  (0-255 byte)
; 0000 00F0     LDI     R20,0x01    ;Load 0x01 into R20
    LDI     R20,0x01    ;Load 0x01 into R20
; 0000 00F1     OUT     0x37,R20    ;R20 --> SPMCSR (BaseAddress: 0x37)
    OUT     0x37,R20    ;R20 --> SPMCSR (BaseAddress: 0x37)
; 0000 00F2     SPM
    SPM
; 0000 00F3 #endasm
; 0000 00F4     WordData = 0; Byte = 0;
	LDI  R30,LOW(0)
	STD  Y+1,R30
	STD  Y+1+1,R30
	ST   Y,R30
; 0000 00F5 }
	ADIW R28,3
	RET
; .FEND
;
;/* Erase a page */
;void boot_page_erase(unsigned char Page)
; 0000 00F9 {
_boot_page_erase:
; .FSTART _boot_page_erase
; 0000 00FA     while(TSTBIT(SPMCSR,0));
	ST   -Y,R26
;	Page -> Y+0
_0x2A:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x2A
; 0000 00FB     //SPMCSR = 0x03;
; 0000 00FC #asm
; 0000 00FD     LDD R31, Y+0
    LDD R31, Y+0
; 0000 00FE     LDI R30, 0x00
    LDI R30, 0x00
; 0000 00FF     LSR R31
    LSR R31
; 0000 0100     ROR R30
    ROR R30
; 0000 0101     PUSH R20
    PUSH R20
; 0000 0102     LDI R20, 0x03
    LDI R20, 0x03
; 0000 0103     OUT 0x37, R20
    OUT 0x37, R20
; 0000 0104     POP R20
    POP R20
; 0000 0105     SPM
    SPM
; 0000 0106 #endasm
; 0000 0107     Page = 0;
	LDI  R30,LOW(0)
	ST   Y,R30
; 0000 0108 }
	JMP  _0x2060001
; .FEND
;
;/* Write a Page */
;void boot_page_write(unsigned char Page)
; 0000 010C {
_boot_page_write:
; .FSTART _boot_page_write
; 0000 010D     //while (SPMEN);
; 0000 010E     while(TSTBIT(SPMCSR,0));
	ST   -Y,R26
;	Page -> Y+0
_0x2D:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x2D
; 0000 010F     //SPMCSR =0x05;
; 0000 0110 #asm
; 0000 0111     LDD R31, Y+0
    LDD R31, Y+0
; 0000 0112     LDI R30, 0x00
    LDI R30, 0x00
; 0000 0113     LSR R31
    LSR R31
; 0000 0114     ROR R30
    ROR R30
; 0000 0115     PUSH R20
    PUSH R20
; 0000 0116     LDI R20, 0x05
    LDI R20, 0x05
; 0000 0117     OUT 0x37, R20
    OUT 0x37, R20
; 0000 0118     POP R20
    POP R20
; 0000 0119     SPM
    SPM
; 0000 011A #endasm
; 0000 011B     Page = 0;
	LDI  R30,LOW(0)
	ST   Y,R30
; 0000 011C }
	JMP  _0x2060001
; .FEND
;
;/* Write to the App. section */
;void WritePage(unsigned char *PageData, unsigned char PageNum)
; 0000 0120 {
_WritePage:
; .FSTART _WritePage
; 0000 0121     unsigned int worddata = 0;
; 0000 0122     unsigned int bytenum = 0;  // 0 to 255
; 0000 0123 
; 0000 0124     boot_page_erase(PageNum);
	ST   -Y,R26
	CALL __SAVELOCR4
;	*PageData -> Y+5
;	PageNum -> Y+4
;	worddata -> R16,R17
;	bytenum -> R18,R19
	__GETWRN 16,17,0
	__GETWRN 18,19,0
	LDD  R26,Y+4
	RCALL _boot_page_erase
; 0000 0125     delay_ms(5);
	LDI  R26,LOW(5)
	LDI  R27,0
	CALL _delay_ms
; 0000 0126     while(bytenum < 128)
_0x30:
	__CPWRN 18,19,128
	BRSH _0x32
; 0000 0127     {
; 0000 0128         worddata = (unsigned int)(PageData[bytenum + 1]*256) + PageData[bytenum];
	MOVW R30,R18
	ADIW R30,1
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	MOV  R31,R30
	LDI  R30,0
	MOVW R0,R30
	MOVW R30,R18
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	LDI  R31,0
	ADD  R30,R0
	ADC  R31,R1
	MOVW R16,R30
; 0000 0129 
; 0000 012A         boot_page_fill(worddata, bytenum);      delay_us(2);
	ST   -Y,R17
	ST   -Y,R16
	MOV  R26,R18
	CALL _boot_page_fill
	__DELAY_USB 11
; 0000 012B         bytenum += 2;
	__ADDWRN 18,19,2
; 0000 012C     }
	RJMP _0x30
_0x32:
; 0000 012D     boot_page_write(PageNum);
	LDD  R26,Y+4
	RCALL _boot_page_write
; 0000 012E     delay_ms(5);
	LDI  R26,LOW(5)
	LDI  R27,0
	CALL _delay_ms
; 0000 012F }
	CALL __LOADLOCR4
	ADIW R28,7
	RET
; .FEND
;
;#include "main.h"
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif
;#include "system.h"
;
;void system_init(){
; 0001 0004 void system_init(){

	.CSEG
_system_init:
; .FSTART _system_init
; 0001 0005    // Crystal Oscillator division factor: 1
; 0001 0006    #pragma optsize-
; 0001 0007    CLKPR=(1<<CLKPCE);
	LDI  R30,LOW(128)
	STS  97,R30
; 0001 0008    CLKPR=(0<<CLKPCE) | (0<<CLKPS3) | (0<<CLKPS2) | (0<<CLKPS1) | (0<<CLKPS0);
	LDI  R30,LOW(0)
	STS  97,R30
; 0001 0009    #ifdef _OPTIMIZE_SIZE_
; 0001 000A    #pragma optsize+
; 0001 000B    #endif
; 0001 000C 
; 0001 000D    // Input/Output Ports initialization
; 0001 000E    // Port B initialization
; 0001 000F    // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=Out Bit0=In
; 0001 0010    DDRB=(0<<DDB7) | (0<<DDB6) | (0<<DDB5) | (0<<DDB4) | (0<<DDB3) | (0<<DDB2) | (1<<DDB1) | (0<<DDB0);
	LDI  R30,LOW(2)
	OUT  0x4,R30
; 0001 0011    // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=0 Bit0=T
; 0001 0012    PORTB=(0<<PORTB7) | (0<<PORTB6) | (0<<PORTB5) | (0<<PORTB4) | (0<<PORTB3) | (0<<PORTB2) | (0<<PORTB1) | (0<<PORTB0);
	LDI  R30,LOW(0)
	OUT  0x5,R30
; 0001 0013 
; 0001 0014    // Port C initialization
; 0001 0015    // Function: Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In
; 0001 0016    DDRC=(0<<DDC6) | (0<<DDC5) | (0<<DDC4) | (0<<DDC3) | (0<<DDC2) | (0<<DDC1) | (0<<DDC0);
	OUT  0x7,R30
; 0001 0017    // State: Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0001 0018    PORTC=(0<<PORTC6) | (0<<PORTC5) | (0<<PORTC4) | (0<<PORTC3) | (0<<PORTC2) | (0<<PORTC1) | (0<<PORTC0);
	OUT  0x8,R30
; 0001 0019 
; 0001 001A    // Port D initialization
; 0001 001B    // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In
; 0001 001C    DDRD=(0<<DDD7) | (0<<DDD6) | (0<<DDD5) | (0<<DDD4) | (0<<DDD3) | (0<<DDD2) | (0<<DDD1) | (0<<DDD0);
	OUT  0xA,R30
; 0001 001D    // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0001 001E    PORTD=(0<<PORTD7) | (0<<PORTD6) | (0<<PORTD5) | (0<<PORTD4) | (0<<PORTD3) | (0<<PORTD2) | (0<<PORTD1) | (0<<PORTD0);
	OUT  0xB,R30
; 0001 001F 
; 0001 0020    // Timer/Counter 0 initialization
; 0001 0021    // Clock source: System Clock
; 0001 0022    // Clock value: Timer 0 Stopped
; 0001 0023    // Mode: Normal top=0xFF
; 0001 0024    // OC0A output: Disconnected
; 0001 0025    // OC0B output: Disconnected
; 0001 0026    TCCR0A=(0<<COM0A1) | (0<<COM0A0) | (0<<COM0B1) | (0<<COM0B0) | (0<<WGM01) | (0<<WGM00);
	OUT  0x24,R30
; 0001 0027    TCCR0B=(0<<WGM02) | (0<<CS02) | (0<<CS01) | (0<<CS00);
	OUT  0x25,R30
; 0001 0028    TCNT0=0x00;
	OUT  0x26,R30
; 0001 0029    OCR0A=0x00;
	OUT  0x27,R30
; 0001 002A    OCR0B=0x00;
	OUT  0x28,R30
; 0001 002B 
; 0001 002C    // Timer/Counter 1 initialization
; 0001 002D    // Clock source: System Clock
; 0001 002E    // Clock value: 16000.000 kHz
; 0001 002F    // Mode: Fast PWM top=ICR1
; 0001 0030    // OC1A output: Non-Inverted PWM
; 0001 0031    // OC1B output: Disconnected
; 0001 0032    // Noise Canceler: Off
; 0001 0033    // Input Capture on Falling Edge
; 0001 0034    // Timer Period: 1 ms
; 0001 0035    // Output Pulse(s):
; 0001 0036    // OC1A Period: 1 ms Width: 0.50003 ms
; 0001 0037    // Timer1 Overflow Interrupt: Off
; 0001 0038    // Input Capture Interrupt: Off
; 0001 0039    // Compare A Match Interrupt: Off
; 0001 003A    // Compare B Match Interrupt: Off
; 0001 003B    TCCR1A=(1<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (1<<WGM11) | (0<<WGM10);
	LDI  R30,LOW(130)
	STS  128,R30
; 0001 003C    TCCR1B=(0<<ICNC1) | (0<<ICES1) | (1<<WGM13) | (1<<WGM12) | (0<<CS12) | (0<<CS11) | (1<<CS10);
	LDI  R30,LOW(25)
	STS  129,R30
; 0001 003D    TCNT1H=0;
	LDI  R30,LOW(0)
	STS  133,R30
; 0001 003E    TCNT1L=0;
	STS  132,R30
; 0001 003F    ICR1H=0x00;
	STS  135,R30
; 0001 0040    ICR1L=0x00;
	STS  134,R30
; 0001 0041    OCR1AH=0x00;
	STS  137,R30
; 0001 0042    OCR1AL=0x00;
	STS  136,R30
; 0001 0043    OCR1BH=0x00;
	STS  139,R30
; 0001 0044    OCR1BL=0x00;
	STS  138,R30
; 0001 0045 
; 0001 0046    // Timer/Counter 2 initialization
; 0001 0047    // Clock source: System Clock
; 0001 0048    // Clock value: Timer2 Stopped
; 0001 0049    // Mode: Normal top=0xFF
; 0001 004A    // OC2A output: Disconnected
; 0001 004B    // OC2B output: Disconnected
; 0001 004C    ASSR=(0<<EXCLK) | (0<<AS2);
	STS  182,R30
; 0001 004D    TCCR2A=(0<<COM2A1) | (0<<COM2A0) | (0<<COM2B1) | (0<<COM2B0) | (0<<WGM21) | (0<<WGM20);
	STS  176,R30
; 0001 004E    TCCR2B=(0<<WGM22) | (0<<CS22) | (0<<CS21) | (0<<CS20);
	STS  177,R30
; 0001 004F    TCNT2=0x00;
	STS  178,R30
; 0001 0050    OCR2A=0x00;
	STS  179,R30
; 0001 0051    OCR2B=0x00;
	STS  180,R30
; 0001 0052 
; 0001 0053    // Timer/Counter 0 Interrupt(s) initialization
; 0001 0054    TIMSK0=(0<<OCIE0B) | (0<<OCIE0A) | (0<<TOIE0);
	STS  110,R30
; 0001 0055 
; 0001 0056    // Timer/Counter 1 Interrupt(s) initialization
; 0001 0057    TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (0<<TOIE1);
	STS  111,R30
; 0001 0058 
; 0001 0059    // Timer/Counter 2 Interrupt(s) initialization
; 0001 005A    TIMSK2=(0<<OCIE2B) | (0<<OCIE2A) | (0<<TOIE2);
	STS  112,R30
; 0001 005B 
; 0001 005C    // External Interrupt(s) initialization
; 0001 005D    // INT0: Off
; 0001 005E    // INT1: Off
; 0001 005F    // Interrupt on any change on pins PCINT0-7: Off
; 0001 0060    // Interrupt on any change on pins PCINT8-14: Off
; 0001 0061    // Interrupt on any change on pins PCINT16-23: Off
; 0001 0062    EICRA=(0<<ISC11) | (0<<ISC10) | (0<<ISC01) | (0<<ISC00);
	STS  105,R30
; 0001 0063    EIMSK=(0<<INT1) | (0<<INT0);
	OUT  0x1D,R30
; 0001 0064    PCICR=(0<<PCIE2) | (0<<PCIE1) | (0<<PCIE0);
	STS  104,R30
; 0001 0065 
; 0001 0066    // USART initialization
; 0001 0067    // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0001 0068    // USART Receiver: On
; 0001 0069    // USART Transmitter: On
; 0001 006A    // USART0 Mode: Asynchronous
; 0001 006B    // USART Baud Rate: 57600 (Double Speed Mode)
; 0001 006C    //UCSR0A=(0<<RXC0) | (0<<TXC0) | (0<<UDRE0) | (0<<FE0) | (0<<DOR0) | (0<<UPE0) | (1<<U2X0) | (0<<MPCM0);
; 0001 006D    //UCSR0B=(0<<RXCIE0) | (0<<TXCIE0) | (0<<UDRIE0) | (1<<RXEN0) | (1<<TXEN0) | (0<<UCSZ02) | (0<<RXB80) | (0<<TXB80);
; 0001 006E    //UCSR0C=(0<<UMSEL01) | (0<<UMSEL00) | (0<<UPM01) | (0<<UPM00) | (0<<USBS0) | (1<<UCSZ01) | (1<<UCSZ00) | (0<<UCPOL0) ...
; 0001 006F    //UBRR0H=0x00;
; 0001 0070    //UBRR0L=0x22;
; 0001 0071 
; 0001 0072    UCSR0A=(0<<RXC0) | (0<<TXC0) | (0<<UDRE0) | (0<<FE0) | (0<<DOR0) | (0<<UPE0) | (1<<U2X0) | (0<<MPCM0);
	LDI  R30,LOW(2)
	STS  192,R30
; 0001 0073    UCSR0B=(1<<RXCIE0) | (1<<TXCIE0) | (0<<UDRIE0) | (1<<RXEN0) | (1<<TXEN0) | (0<<UCSZ02) | (0<<RXB80) | (0<<TXB80);
	LDI  R30,LOW(216)
	STS  193,R30
; 0001 0074    UCSR0C=(0<<UMSEL01) | (0<<UMSEL00) | (0<<UPM01) | (0<<UPM00) | (0<<USBS0) | (1<<UCSZ01) | (1<<UCSZ00) | (0<<UCPOL0);
	LDI  R30,LOW(6)
	STS  194,R30
; 0001 0075    UBRR0H=0x00;
	LDI  R30,LOW(0)
	STS  197,R30
; 0001 0076    UBRR0L=0x22;
	LDI  R30,LOW(34)
	STS  196,R30
; 0001 0077 
; 0001 0078    // Analog Comparator initialization
; 0001 0079    // Analog Comparator: Off
; 0001 007A    // The Analog Comparator's positive input is
; 0001 007B    // connected to the AIN0 pin
; 0001 007C    // The Analog Comparator's negative input is
; 0001 007D    // connected to the AIN1 pin
; 0001 007E    ACSR=(1<<ACD) | (0<<ACBG) | (0<<ACO) | (0<<ACI) | (0<<ACIE) | (0<<ACIC) | (0<<ACIS1) | (0<<ACIS0);
	LDI  R30,LOW(128)
	OUT  0x30,R30
; 0001 007F    ADCSRB=(0<<ACME);
	LDI  R30,LOW(0)
	STS  123,R30
; 0001 0080    // Digital input buffer on AIN0: On
; 0001 0081    // Digital input buffer on AIN1: On
; 0001 0082    DIDR1=(0<<AIN0D) | (0<<AIN1D);
	STS  127,R30
; 0001 0083 
; 0001 0084    // ADC initialization
; 0001 0085    // ADC disabled
; 0001 0086    ADCSRA=(0<<ADEN) | (0<<ADSC) | (0<<ADATE) | (0<<ADIF) | (0<<ADIE) | (0<<ADPS2) | (0<<ADPS1) | (0<<ADPS0);
	STS  122,R30
; 0001 0087 
; 0001 0088    // SPI initialization
; 0001 0089    // SPI disabled
; 0001 008A    SPCR=(0<<SPIE) | (0<<SPE) | (0<<DORD) | (0<<MSTR) | (0<<CPOL) | (0<<CPHA) | (0<<SPR1) | (0<<SPR0);
	OUT  0x2C,R30
; 0001 008B 
; 0001 008C    // TWI initialization
; 0001 008D    // TWI disabled
; 0001 008E    TWCR=(0<<TWEA) | (0<<TWSTA) | (0<<TWSTO) | (0<<TWEN) | (0<<TWIE);
	STS  188,R30
; 0001 008F }
	RET
; .FEND
;#include "main.h"
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif
;#include "protocol.h"
;
;#define DATA_REGISTER_EMPTY (1<<UDRE0)
;#define RX_COMPLETE (1<<RXC0)
;#define FRAMING_ERROR (1<<FE0)
;#define PARITY_ERROR (1<<UPE0)
;#define DATA_OVERRUN (1<<DOR0)
;
;// USART Receiver buffer
;char rx_buffer0[RX_BUFFER_SIZE0];
;
;#if RX_BUFFER_SIZE0 <= 256
;unsigned char rx_wr_index0=0,rx_rd_index0=0;
;#else
;unsigned int rx_wr_index0=0,rx_rd_index0=0;
;#endif
;
;#if RX_BUFFER_SIZE0 < 256
;unsigned char rx_counter0=0;
;#else
;unsigned int rx_counter0=0;
;#endif
;
;// This flag is set on USART Receiver buffer overflow
;bit rx_buffer_overflow0;
;
;// USART Receiver interrupt service routine
;interrupt [USART_RXC] void usart_rx_isr(void)
; 0002 001E {

	.CSEG
_usart_rx_isr:
; .FSTART _usart_rx_isr
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0002 001F    char status,data;
; 0002 0020    status=UCSR0A;
	ST   -Y,R17
	ST   -Y,R16
;	status -> R17
;	data -> R16
	LDS  R17,192
; 0002 0021    data=UDR0;
	LDS  R16,198
; 0002 0022    if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BRNE _0x40003
; 0002 0023       {
; 0002 0024       rx_buffer0[rx_wr_index0++]=data;
	LDS  R30,_rx_wr_index0
	SUBI R30,-LOW(1)
	STS  _rx_wr_index0,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	ST   Z,R16
; 0002 0025    #if RX_BUFFER_SIZE0 == 256
; 0002 0026       // special case for receiver buffer size=256
; 0002 0027       if (++rx_counter0 == 0) rx_buffer_overflow0=1;
; 0002 0028    #else
; 0002 0029       if (rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0=0;
	LDS  R26,_rx_wr_index0
	CPI  R26,LOW(0x96)
	BRNE _0x40004
	LDI  R30,LOW(0)
	STS  _rx_wr_index0,R30
; 0002 002A       if (++rx_counter0 == RX_BUFFER_SIZE0)
_0x40004:
	LDS  R26,_rx_counter0
	SUBI R26,-LOW(1)
	STS  _rx_counter0,R26
	CPI  R26,LOW(0x96)
	BRNE _0x40005
; 0002 002B          {
; 0002 002C          rx_counter0=0;
	LDI  R30,LOW(0)
	STS  _rx_counter0,R30
; 0002 002D          rx_buffer_overflow0=1;
	SBI  0x1E,0
; 0002 002E          }
; 0002 002F    #endif
; 0002 0030       }
_0x40005:
; 0002 0031 }
_0x40003:
	LD   R16,Y+
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
; .FEND
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Get a character from the USART Receiver buffer
;#define _ALTERNATE_GETCHAR_
;#pragma used+
;char getchar(void)
; 0002 0038 {
_getchar:
; .FSTART _getchar
; 0002 0039    char data;
; 0002 003A    while (rx_counter0==0);
	ST   -Y,R17
;	data -> R17
_0x40008:
	LDS  R30,_rx_counter0
	CPI  R30,0
	BREQ _0x40008
; 0002 003B    data=rx_buffer0[rx_rd_index0++];
	LDS  R30,_rx_rd_index0
	SUBI R30,-LOW(1)
	STS  _rx_rd_index0,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	LD   R17,Z
; 0002 003C    #if RX_BUFFER_SIZE0 != 256
; 0002 003D    if (rx_rd_index0 == RX_BUFFER_SIZE0) rx_rd_index0=0;
	LDS  R26,_rx_rd_index0
	CPI  R26,LOW(0x96)
	BRNE _0x4000B
	LDI  R30,LOW(0)
	STS  _rx_rd_index0,R30
; 0002 003E    #endif
; 0002 003F    #asm("cli")
_0x4000B:
	cli
; 0002 0040    --rx_counter0;
	LDS  R30,_rx_counter0
	SUBI R30,LOW(1)
	STS  _rx_counter0,R30
; 0002 0041    #asm("sei")
	sei
; 0002 0042    return data;
	MOV  R30,R17
_0x2060002:
	LD   R17,Y+
	RET
; 0002 0043 }
; .FEND
;#pragma used-
;#endif
;
;// USART Transmitter buffer
;#define TX_BUFFER_SIZE0 8
;char tx_buffer0[TX_BUFFER_SIZE0];
;
;#if TX_BUFFER_SIZE0 <= 256
;unsigned char tx_wr_index0=0,tx_rd_index0=0;
;#else
;unsigned int tx_wr_index0=0,tx_rd_index0=0;
;#endif
;
;#if TX_BUFFER_SIZE0 < 256
;unsigned char tx_counter0=0;
;#else
;unsigned int tx_counter0=0;
;#endif
;
;// USART Transmitter interrupt service routine
;interrupt [USART_TXC] void usart_tx_isr(void)
; 0002 0059 {
_usart_tx_isr:
; .FSTART _usart_tx_isr
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0002 005A    if (tx_counter0)
	TST  R10
	BREQ _0x4000C
; 0002 005B       {
; 0002 005C       --tx_counter0;
	DEC  R10
; 0002 005D       UDR0=tx_buffer0[tx_rd_index0++];
	MOV  R30,R7
	INC  R7
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer0)
	SBCI R31,HIGH(-_tx_buffer0)
	LD   R30,Z
	STS  198,R30
; 0002 005E    #if TX_BUFFER_SIZE0 != 256
; 0002 005F       if (tx_rd_index0 == TX_BUFFER_SIZE0) tx_rd_index0=0;
	LDI  R30,LOW(8)
	CP   R30,R7
	BRNE _0x4000D
	CLR  R7
; 0002 0060    #endif
; 0002 0061       }
_0x4000D:
; 0002 0062 }
_0x4000C:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	RETI
; .FEND
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Write a character to the USART Transmitter buffer
;#define _ALTERNATE_PUTCHAR_
;#pragma used+
;void putchar(char c)
; 0002 0069 {
_putchar:
; .FSTART _putchar
; 0002 006A    while (tx_counter0 == TX_BUFFER_SIZE0);
	ST   -Y,R26
;	c -> Y+0
_0x4000E:
	LDI  R30,LOW(8)
	CP   R30,R10
	BREQ _0x4000E
; 0002 006B    #asm("cli")
	cli
; 0002 006C    if (tx_counter0 || ((UCSR0A & DATA_REGISTER_EMPTY)==0))
	TST  R10
	BRNE _0x40012
	LDS  R30,192
	ANDI R30,LOW(0x20)
	BRNE _0x40011
_0x40012:
; 0002 006D       {
; 0002 006E       tx_buffer0[tx_wr_index0++]=c;
	MOV  R30,R8
	INC  R8
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer0)
	SBCI R31,HIGH(-_tx_buffer0)
	LD   R26,Y
	STD  Z+0,R26
; 0002 006F    #if TX_BUFFER_SIZE0 != 256
; 0002 0070       if (tx_wr_index0 == TX_BUFFER_SIZE0) tx_wr_index0=0;
	LDI  R30,LOW(8)
	CP   R30,R8
	BRNE _0x40014
	CLR  R8
; 0002 0071    #endif
; 0002 0072       ++tx_counter0;
_0x40014:
	INC  R10
; 0002 0073       }
; 0002 0074    else
	RJMP _0x40015
_0x40011:
; 0002 0075       UDR0=c;
	LD   R30,Y
	STS  198,R30
; 0002 0076    #asm("sei")
_0x40015:
	sei
; 0002 0077 }
_0x2060001:
	ADIW R28,1
	RET
; .FEND
;#pragma used-
;#endif

	.CSEG
_memcpy:
; .FSTART _memcpy
	ST   -Y,R27
	ST   -Y,R26
    ldd  r25,y+1
    ld   r24,y
    adiw r24,0
    breq memcpy1
    ldd  r27,y+5
    ldd  r26,y+4
    ldd  r31,y+3
    ldd  r30,y+2
memcpy0:
    ld   r22,z+
    st   x+,r22
    sbiw r24,1
    brne memcpy0
memcpy1:
    ldd  r31,y+5
    ldd  r30,y+4
	ADIW R28,6
	RET
; .FEND
_strncpy:
; .FSTART _strncpy
	ST   -Y,R26
    ld   r23,y+
    ld   r30,y+
    ld   r31,y+
    ld   r26,y+
    ld   r27,y+
    movw r24,r26
strncpy0:
    tst  r23
    breq strncpy1
    dec  r23
    ld   r22,z+
    st   x+,r22
    tst  r22
    brne strncpy0
strncpy2:
    tst  r23
    breq strncpy1
    dec  r23
    st   x+,r22
    rjmp strncpy2
strncpy1:
    movw r30,r24
    ret
; .FEND
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif

	.CSEG

	.CSEG

	.DSEG
_rx_wr_index0:
	.BYTE 0x1
_rx_rd_index0:
	.BYTE 0x1
_rx_counter0:
	.BYTE 0x1
_rx_buffer0:
	.BYTE 0x96
_fw_version:
	.BYTE 0x6
_request:
	.BYTE 0x9C
_respond:
	.BYTE 0x9C
_upgrade_page_request:
	.BYTE 0x81
_tx_buffer0:
	.BYTE 0x8

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x0:
	LDI  R30,LOW(0)
	STS  _rx_rd_index0,R30
	STS  _rx_wr_index0,R30
	STS  _rx_counter0,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x1:
	LDI  R26,LOW(1)
	LDI  R27,0
	JMP  _send_respond


	.CSEG
_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0xFA0
	wdr
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:
