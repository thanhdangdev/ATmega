/*******************************************************
This program was created by the
CodeWizardAVR V3.12 Advanced
Automatic Program Generator
? Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project :
Version :
Date    : 8/8/2018
Author  :
Company :
Comments:


Chip type               : ATmega328P
Program type            : Application
AVR Core Clock frequency: 16.000000 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 512
*******************************************************/
#include "main.h"
#include "system.h"
#include "protocol.h"
#include <iobits.h>

/* definitions for SPM control */
#define	SPMCR_REG	SPMCSR
#asm
     #define WR_SPMCR_REG_R22 out 0x37,r22
#endasm

#define _ENABLE_RWW_SECTION() __DataToR0ByteToSPMCR_SPM( 0x00, 0x11 )
#define _WAIT_FOR_SPM() while( SPMCR_REG & (1<<SELFPRGEN) );
void __DataToR0ByteToSPMCR_SPM(unsigned char data, unsigned char ctrl);

// Declare your global variables here

char hw_version = 0;
char fw_version[] = "0.0.0";

serial_command_t request;
serial_command_t respond;

unsigned char get_status = GET_STATUS_COMPLETE;
unsigned char len = 0;

upgrade_page_request_t upgrade_page_request;

bool isUpgrade = true;

void main(void)
{
    system_init();
   
    // Global enable interrupts
    #asm("sei")
    while (1)
    {
        if(getCommand()){
            process_request();

            #asm("cli")
            rx_counter0 = rx_wr_index0 = rx_rd_index0 = 0 ;
            #asm("sei")
        }
      
        if(!isUpgrade){
            #asm("cli")

            // Jump to application
//            #asm
//            LDI     R30, 0x00
//            LDI     R31, 0x00
//            IJMP               ;Jump to address 0x0000
//            #endasm
            #pragma optsize-
            // will use the interrupt vectors from the application section
            MCUCR=(1<<IVCE);
            MCUCR=(0<<IVSEL) | (0<<IVCE);
            #ifdef _OPTIMIZE_SIZE_
            #pragma optsize+
            #endif

            // start execution from address 0
            #asm("jmp 0")
        }
        delay_ms(5);
    }
}

bool getCommand(){
     // Place your code here
      if(get_status == GET_STATUS_COMPLETE && rx_counter0 >= 7){
         if(getchar() == 0xFF){
            if(getchar() == 0x55){
               len = getchar();
               if(len <= 157){
                  get_status = GET_STATUS_GETTING;

               }
            }else{
               #asm("cli")
                rx_counter0 = rx_wr_index0 = rx_rd_index0 = 0 ;
               #asm("sei")
            }
         }else{
            #asm("cli")
            rx_counter0 = rx_wr_index0 = rx_rd_index0 = 0 ;
            #asm("sei")
         }
      }

      if(get_status == GET_STATUS_GETTING){
         if(rx_counter0 >= len - 1){
            memcpy(&request, &rx_buffer0, len + 2);
            get_status =  GET_STATUS_COMPLETE;
            
            return true;
         }
      }
      
      return false;
}

void process_request(){
   unsigned char len = request.len;

   if(checksum(&request.len, len) != 0){
      response_error_checksum();
   }else{
      execute_cmd();
   }
}

unsigned char checksum(unsigned char *dat, unsigned char len){
   unsigned char ck  = 0;
   unsigned char i = 0;

   for(i = 0; i<len; i++){
      ck += *(dat + i);
   }

   return ck;
}

void response_error_checksum(){
    unsigned char status = STATUS_ERROR_CHECKSUM;
    send_respond((char *)&status, sizeof(status));
}

void execute_cmd(){
    unsigned char status;
    switch(request.opcode){
    case CMD_READ_VERSION:
        process_read_version();
        break;
    case CMD_UPGRADE_START:
        process_upgrade_start();
        break;
    case CMD_UPGRADE_PAGE:
        process_upgrade_page();
        break;
    case CMD_UPGRADE_FINISH:
        process_upgrade_finish();
        break;
    default:
        status = STATUS_UNSUPPORT;
        send_respond((char *)&status, sizeof(status));
        break;
    }
}

void process_upgrade_start(){
    unsigned char status = STATUS_SUCCESS;
    send_respond((char*)&status, sizeof(status));
}

void process_read_version(){
    char *c;
    char str[] = "0.0.0";
    respond_read_version_t res;
    unsigned char hw0 = PIND.6;
    unsigned char hw1 = PIND.7;
    //hw_version = (hw1 << 1) | (hw0 << 0);

    res.status = STATUS_SUCCESS;
    hw_version = hw1 * 2 + hw0 + 1;
    strncpy(res.hw_version, str, 5);
    res.hw_version[0] = hw_version + 0x30;
    strncpy(res.fw_version, fw_version, 5);
    send_respond((char *)&res, sizeof(res));
}

void send_respond(char * payload, unsigned short len){
    unsigned char i;
    unsigned char checksum = 0;
    unsigned char *c;
    respond.header = 0x55FF;
    respond.len = 5 + len;
    respond.tranId = request.tranId;
    respond.opcode = request.opcode;
    respond.type = TYPE_RESPOND;

    memcpy(respond.payload, payload, len);

    for(i = 0; i< respond.len - 1; i++){
        checksum += *(&respond.len + i);
    }

    checksum = ~checksum + 1;

    c = (char*)&respond;
    for(i = 0; i<respond.len + 1; i++){
        putchar(c[i]);
    }
    putchar(checksum);
}

void process_upgrade_page()
{
    unsigned char status = STATUS_SUCCESS;
    memcpy(&upgrade_page_request, request.payload, sizeof(upgrade_page_request));

    #asm("cli")

    // Write page
    WritePage(upgrade_page_request.page_data, upgrade_page_request.page);

    #asm("sei")

    send_respond((char*)&status, sizeof(status));
}

void process_upgrade_finish()
{
    // respond
    unsigned char status = STATUS_SUCCESS;
    send_respond((char*)&status, sizeof(status));

    delay_ms(10);

    _WAIT_FOR_SPM();
    _ENABLE_RWW_SECTION();

    isUpgrade = false;
}

/* Fill data into a temporary page (2 bytes once) */
void boot_page_fill(unsigned int WordData, unsigned char Byte)
{
    //while (SPMEN);
    while(TSTBIT(SPMCSR,0));
#asm
    LDD     R1, Y+2     ;R1  <-- MSB of data (Byte N)
    LDD     R0, Y+1     ;R0  <-- LSB of data (Byte N+1)
    LDI     R31, 0x00   ;Load 0x00 into R31
    LDD     R30, Y+0    ;R30 <-- addr  (0-255 byte)
    LDI     R20,0x01    ;Load 0x01 into R20
    OUT     0x37,R20    ;R20 --> SPMCSR (BaseAddress: 0x37)
    SPM
#endasm
    WordData = 0; Byte = 0;
}

/* Erase a page */
void boot_page_erase(unsigned char Page)
{
    while(TSTBIT(SPMCSR,0));
    //SPMCSR = 0x03;
#asm
    LDD R31, Y+0
    LDI R30, 0x00
    LSR R31
    ROR R30
    PUSH R20
    LDI R20, 0x03
    OUT 0x37, R20
    POP R20
    SPM
#endasm
    Page = 0;
}

/* Write a Page */
void boot_page_write(unsigned char Page)
{
    //while (SPMEN);
    while(TSTBIT(SPMCSR,0));
    //SPMCSR =0x05;
#asm
    LDD R31, Y+0
    LDI R30, 0x00
    LSR R31
    ROR R30
    PUSH R20
    LDI R20, 0x05
    OUT 0x37, R20
    POP R20
    SPM
#endasm
    Page = 0;
}

/* Write to the App. section */
void WritePage(unsigned char *PageData, unsigned char PageNum)
{
    unsigned int worddata = 0;
    unsigned int bytenum = 0;  // 0 to 255

    boot_page_erase(PageNum);
    delay_ms(5);
    while(bytenum < 128)
    {
        worddata = (unsigned int)(PageData[bytenum + 1]*256) + PageData[bytenum];

        boot_page_fill(worddata, bytenum);      delay_us(2);
        bytenum += 2;
    }
    boot_page_write(PageNum);
    delay_ms(5);
}

void __DataToR0ByteToSPMCR_SPM(unsigned char data, unsigned char ctrl)
{
#asm
     ldd  r0,y+1
     ld   r22,y
     WR_SPMCR_REG_R22
     spm
#endasm
}

