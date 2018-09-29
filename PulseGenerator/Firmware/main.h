#ifndef _MAIN_H_
#define _MAIN_H_

#include <mega328p.h>
#include <delay.h>
#include <string.h>
// Standard Input/Output functions
#include <stdio.h>
#include <stdbool.h>

enum{
    TYPE_REQUEST = 1,
    TYPE_RESPOND
};

enum{
    CMD_READ_VERSION = 1,
    CMD_TEST_TRANSFER = 2,
    CMD_WRITE_REGISTER = 3
};

#define GET_STATUS_COMPLETE 0
#define GET_STATUS_GETTING  1

typedef struct serial_command_t{
    unsigned short header;  // 0xFF55
    unsigned char len;
    unsigned char type;
    unsigned char tranId;
    unsigned char opcode;
    unsigned char payload[128];
}serial_command_t;

typedef struct respond_read_version_t{
   char hw_version[5];  // "1.0.0";
   char fw_version[5];
}respond_read_version_t;

typedef struct Payload_Write_Register{
    unsigned char reg_TCCR1A;
    unsigned char reg_TCCR1B;
    unsigned char reg_ICR1H;
    unsigned char reg_ICR1L;
    unsigned char reg_OCR1AH;
    unsigned char reg_OCR1AL;
}Payload_Write_Register;

bool getCommand();
void process_request();
unsigned char checksum(unsigned char *dat, unsigned char len);
void execute_cmd();
void process_read_version();
void process_write_register();
void send_respond(char * payload, unsigned short len);


#endif

