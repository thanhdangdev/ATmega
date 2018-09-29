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

// Declare your global variables here

char hw_version = 0;
char fw_version[] = "1.0.0";

serial_command_t request;
serial_command_t respond;

unsigned char get_status = GET_STATUS_COMPLETE;
unsigned char len = 0;

Payload_Write_Register pl_write_register;

void main(void)
{
   // Declare your local variables here
   
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
      
      

   }
}

bool getCommand(){
     // Place your code here
      if(get_status == GET_STATUS_COMPLETE && rx_counter0 >= 7){
         if(getchar() == 0xFF){
            if(getchar() == 0x55){
               len = getchar();
               if(len <= 135){
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
      //response_error_checksum();
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

}

void execute_cmd(){
   switch(request.opcode){
   case CMD_READ_VERSION:
       process_read_version();

       break;
   case CMD_WRITE_REGISTER:  
      process_write_register();
      break;
   default:
       //response_unsupport();
       break;
   }
}

void process_read_version(){
    char *c;
   char str[] = "0.0.0";
   unsigned char checksum = 0;
   unsigned short i;
   respond_read_version_t res;
   unsigned char hw0 = PIND.6;
   unsigned char hw1 = PIND.7;
   //hw_version = (hw1 << 1) | (hw0 << 0);


   hw_version = hw1 * 2 + hw0 + 1;
   strncpy(res.hw_version, str, 5);
   res.hw_version[0] = hw_version + 0x30;
   strncpy(res.fw_version, fw_version, 5);


   send_respond((char *)&res, sizeof(res));
}

void process_write_register(){
   memcpy(&pl_write_register, request.payload, sizeof(pl_write_register));
   
   TCCR1A = pl_write_register.reg_TCCR1A;
   TCCR1B = pl_write_register.reg_TCCR1B;
   ICR1H = pl_write_register.reg_ICR1H;
   ICR1L = pl_write_register.reg_ICR1L;
   OCR1AH= pl_write_register.reg_OCR1AH;
   OCR1AL=pl_write_register.reg_OCR1AL; 
   
   //send_respond();
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
    for(i = 0; i<respond.len + 2; i++){
         putchar(c[i]);
     }
}
