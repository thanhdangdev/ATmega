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
    CMD_WRITE_REGISTER = 3,
    CMD_UPGRADE_START = 4,
    CMD_UPGRADE_PAGE = 5,
    CMD_UPGRADE_FINISH = 6
};

enum{
    STATUS_SUCCESS = 0,
    STATUS_FAIL = 1,
    STATUS_ERROR_CHECKSUM = 2,
    STATUS_UNSUPPORT = 3
};

#define GET_STATUS_COMPLETE 0
#define GET_STATUS_GETTING  1

typedef struct serial_command_t{
    unsigned short header;  // 0xFF55
    unsigned char len;
    unsigned char type;
    unsigned char tranId;
    unsigned char opcode;
    unsigned char payload[150];
}serial_command_t;

typedef struct respond_read_version_t{
   char status;
   char hw_version[5];  // "1.0.0";
   char fw_version[5];
}respond_read_version_t;

typedef struct test_transfer_request_t{
    unsigned char len;
    unsigned char data[128];
}test_transfer_request_t;

typedef struct test_transfer_respond_t{
    char status;
    unsigned char len;
    unsigned char data[128];
}test_transfer_respond_t;

typedef struct Payload_Write_Register{
    unsigned char reg_TCCR1A;
    unsigned char reg_TCCR1B;
    unsigned char reg_ICR1H;
    unsigned char reg_ICR1L;
    unsigned char reg_OCR1AH;
    unsigned char reg_OCR1AL;
}Payload_Write_Register;

typedef struct upgrade_page_request_t{
    unsigned char page;
    unsigned char page_data[128];
}upgrade_page_request_t;

bool getCommand();
void process_request();
unsigned char checksum(unsigned char *dat, unsigned char len);
void execute_cmd();
void process_read_version();
void process_upgrade_start();
void process_upgrade_page();
void process_upgrade_finish();
void send_respond(char * payload, unsigned short len);
void response_error_checksum();

void boot_page_fill(unsigned int WordData, unsigned char Byte);
void boot_page_erase(unsigned char Page);
void boot_page_write(unsigned char Page);
void WritePage(unsigned char *PageData, unsigned char PageNum);


#endif

