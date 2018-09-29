#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QSerialPort>
#include <QLabel>
#include <QTimer>
#include <QFileDialog>
#include "Files/ihex/ihex_utils.h"

namespace Ui {
class MainWindow;
}

#pragma pack(1)
typedef struct serial_command{
    unsigned short header = 0xFF55;  // 0xFF55
    unsigned char len;
    unsigned char type;
    unsigned char tranId;
    unsigned char opcode;
    unsigned char payload[150];
}serial_command;

enum{
    TYPE_REQUEST = 1,
    TYPE_RESPOND
};

enum{
    STATUS_SUCCESS = 0,
    STATUS_FAIL = 1,
    STATUS_ERROR_CHECKSUM = 2,
    STATUS_UNSUPPORT = 3
};

enum{
    CMD_READ_VERSION = 1,
    CMD_TEST_TRANSFER = 2,
    CMD_WRITE_REGISTER = 3,
    CMD_UPGRADE_START = 4,
    CMD_UPGRADE_PAGE = 5,
    CMD_UPGRADE_FINISH = 6
};


typedef struct Payload_Write_Register{
    unsigned char TCCR1A;
    unsigned char TCCR1B;
    unsigned char ICR1H;
    unsigned char ICR1L;
    unsigned char OCR1AH;
    unsigned char OCR1AL;
}Payload_Write_Register;

typedef struct Payload_Read_Version_Respond{
    unsigned char status;
    char hw_version[5];
    char fw_version[5];
}Payload_Read_Version_Respond;

typedef struct test_transfer_request_t{
    unsigned char len;
    unsigned char data[128];
}test_transfer_request_t;

typedef struct test_transfer_respond_t{
    char status;
    unsigned char len;
    unsigned char data[128];
}test_transfer_respond_t;

typedef struct upgrade_start_respond_t{
    char status;
}upgrade_start_respond_t;

typedef struct upgrade_page_request_t{
    unsigned char page;
    unsigned char page_data[128];
}upgrade_page_request_t;

typedef struct upgrade_page_respond_t{
    char status;
}upgrade_page_respond_t;

typedef struct upgrade_finish_respond_t{
    char status;
}upgrade_finish_respond_t;

#pragma pack()

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void on_dialFine_valueChanged(int value);

    void on_dialCoarse_valueChanged(int value);

    void on_verticalSliderRange_valueChanged(int value);
    QByteArray transaction(const QByteArray &request, int waitTimeout);
    void on_pushButtonGetVersion_clicked();
    QByteArray createRequest(unsigned char type, unsigned char tranId, unsigned char opcode, unsigned char *payload, unsigned char len);

    void on_dialCoarse_sliderReleased();

    void on_dialFine_sliderReleased();

    void on_dialDutyCycle_sliderReleased();

    void writeRegisters();

    void on_verticalSliderRange_sliderReleased();

    void on_pushButtonTestTransfer_clicked();

    bool test_transfer();

    void on_timerTestTransfer_timeout();

    int randBetween(int low, int high);

    void on_pushButtonUpgradeFirmware_clicked();

    bool upgrade_start();
    bool upgrade_page(unsigned char page, unsigned char * page_data);
    bool upgrade_finish();

    void on_pushButtonStartApp_clicked();

private:
    Ui::MainWindow *ui;
    QSerialPort * port;
    QLabel labelStatus;
    QTimer timerTestTransfer;
};

#endif // MAINWINDOW_H
