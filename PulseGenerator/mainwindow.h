#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QSerialPort>
#include <QLabel>

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
    unsigned char payload[128];
}serial_command;

enum{
    TYPE_REQUEST = 1,
    TYPE_RESPOND
};

enum{
    CMD_READ_VERSION = 1,
    CMD_TEST_TRANSFER = 2,
    CMD_WRITE_REGISTER = 3
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
    char hw_version[5];
    char fw_version[5];
}Payload_Read_Version_Respond;
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

private:
    Ui::MainWindow *ui;
    QSerialPort * port;
    QLabel labelStatus;
};

#endif // MAINWINDOW_H
