#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "PrintDebug/printdebug.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    this->setFixedSize(this->width(), this->height());
    ui->statusBar->addWidget(&labelStatus);
    this->labelStatus.setText("FW version: ???");

    port = new QSerialPort();

    port->setPortName("COM1");
    port->setBaudRate(QSerialPort::Baud57600);
    port->setDataBits(QSerialPort::Data8);
    port->setStopBits(QSerialPort::OneStop);
    port->setParity(QSerialPort::NoParity);
    port->setFlowControl(QSerialPort::NoFlowControl);

    port->open(QIODevice::ReadWrite);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_dialFine_valueChanged(int value)
{
    Q_UNUSED(value);

    int freq = 0;
    int range = ui->verticalSliderRange->value();
    int coarse = ui->dialCoarse->value();
    int fine = ui->dialFine->value();

    freq = range * (coarse * 99 + fine);
    ui->lcdNumberFrequency->display(freq);
}

void MainWindow::on_dialCoarse_valueChanged(int value)
{
    on_dialFine_valueChanged(value);
}

void MainWindow::on_verticalSliderRange_valueChanged(int value)
{
    on_dialFine_valueChanged(value);
}

QByteArray MainWindow::transaction(const QByteArray &request, int waitTimeout)
{
    QByteArray responseData;

    // write request
    printBuffer8("Request", request);
    port->write(request);
    if ( port->waitForBytesWritten(waitTimeout)) {
        // read response
        if ( port->waitForReadyRead(waitTimeout)) {
            responseData =  port->readAll();
            while( port->waitForReadyRead(20))
                responseData +=  port->readAll();

            printBuffer8("Respone", responseData);
        }else{
            qDebug()<<"No respone";
        }
    }else{
        qDebug()<<"Can't write to port";
    }

    return responseData;
}




void MainWindow::on_pushButtonGetVersion_clicked()
{

    Payload_Read_Version_Respond *pl;

    QByteArray request = createRequest(TYPE_REQUEST, 0, CMD_READ_VERSION, NULL, 0);
    printBuffer8("Request", request);
    QByteArray respond = transaction(request, 1000);

    if(!respond.isEmpty()){
        serial_command * cmd_respond = (serial_command*)respond.data();
        pl = (Payload_Read_Version_Respond*)(cmd_respond->payload);

        QString fw_version = QString().fromLatin1(pl->fw_version, sizeof(pl->fw_version));
        this->labelStatus.setText("FW version = " + fw_version);
    }
}

QByteArray MainWindow::createRequest(unsigned char type, unsigned char tranId, unsigned char opcode, unsigned char *payload, unsigned char len)
{
    QByteArray request;

    request.append(0xFF);
    request.append(0x55);
    request.append(len + 5);        // 2
    request.append(type);
    request.append(tranId);
    request.append(opcode);
    if(len){
        request.append((char*)payload, len);
    }

    unsigned char ck = 0;
    for(unsigned char i = 2; i<request.length(); i++){
        ck += (unsigned char)request.at(i);
    }

//    ck = 256 - ck;
    ck = ~ck + 1;
    request.append(ck);

    return request;
}

void MainWindow::on_dialCoarse_sliderReleased()
{
    writeRegisters();
}

void MainWindow::on_dialFine_sliderReleased()
{
    writeRegisters();
}

void MainWindow::writeRegisters()
{
    // fpwm = 10000, duty = 50
    // fcpu = 16000000
    // pres = fcpu / fpwm
    // ICR  = fcpu / (fpwm * pres)
    // OCR  = ICR * Duty / 100

    Payload_Write_Register pl;
    double fcpu = 16000000;
    double fpwm = 10000;

    int range = ui->verticalSliderRange->value();
    int coarse = ui->dialCoarse->value();
    int fine = ui->dialFine->value();
    fpwm = range * (coarse * 99 + fine);
    if(fpwm){
        uint8_t duty = ui->dialDutyCycle->value();

        qDebug()<< "Frequency:" << fpwm << "Duty:" << duty;

        uint16_t pres = fcpu / fpwm;

        uint8_t CS = 0;
        if(fpwm < 10){
            pres = 256;
            CS = 4;
        }else if(fpwm < 100){
            pres = 64;
            CS = 3;
        }else if(fpwm < 1000){
            pres = 8;
            CS = 2;
        }else{
            pres = 1;
            CS = 1;
        }

        //fpwm = 10000;
        // 16000000 / 10240000
        uint16_t ICR = fcpu / (fpwm * pres) - 1;
        uint16_t OCR = (uint32_t)ICR * duty / 100;

        pl.TCCR1A = 0x82;
        pl.TCCR1B = (0x19 & 0xF8) | CS;

        pl.ICR1H = (ICR >> 8) & 0xFF;
        pl.ICR1L = ICR & 0xFF;
        pl.OCR1AH = (OCR >> 8) & 0xFF;
        pl.OCR1AL = OCR & 0xFF;

        qDebug() << "fpwm"<<fpwm<<", Pres" << pres;
        qDebug() << "ICR:" << QString().sprintf("%04X", ICR)
                 << ", ICR1L" << QString().sprintf("%04X", pl.ICR1L)
                 << ", ICR1H" << QString().sprintf("%04X", pl.ICR1H);
        qDebug() << "OCR:" << QString().sprintf("%04X", OCR)
                 << ", OCR1L" << QString().sprintf("%04X", pl.OCR1AL)
                 << ", OCR1H" << QString().sprintf("%04X", pl.OCR1AH);

    }else{
        pl.TCCR1A = 0x02;
    }

    QByteArray request = createRequest(TYPE_REQUEST, 0, CMD_WRITE_REGISTER, (unsigned char*)&pl, sizeof(pl));
    printBuffer8("Request", request);
    transaction(request, 1000);
}

void MainWindow::on_dialDutyCycle_sliderReleased()
{
    writeRegisters();
}

void MainWindow::on_verticalSliderRange_sliderReleased()
{
    writeRegisters();
}
