#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "PrintDebug/printdebug.h"
#include <unistd.h>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    qsrand(qrand());

    this->setFixedSize(this->width(), this->height());
    ui->statusBar->addWidget(&labelStatus);
    this->labelStatus.setText("FW version: ???");

    port = new QSerialPort();

    port->setPortName("COM9");
    port->setBaudRate(QSerialPort::Baud57600);
    port->setDataBits(QSerialPort::Data8);
    port->setStopBits(QSerialPort::OneStop);
    port->setParity(QSerialPort::NoParity);
    port->setFlowControl(QSerialPort::NoFlowControl);

    port->open(QIODevice::ReadWrite);

    QObject::connect(&this->timerTestTransfer, SIGNAL(timeout()),
                     this, SLOT(on_timerTestTransfer_timeout()));
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
    if (port->waitForBytesWritten(waitTimeout)) {
        // read response
        if ( port->waitForReadyRead(waitTimeout)) {
            responseData =  port->readAll();
            while(port->waitForReadyRead(20))
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

int total_cmd = 0;
int success_cmd = 0;
void MainWindow::on_pushButtonTestTransfer_clicked()
{
    //test_transfer();
    if(ui->pushButtonTestTransfer->isChecked()){
        total_cmd = 0;
        success_cmd = 0;
        this->timerTestTransfer.start(1000);
    }else{
        this->timerTestTransfer.stop();
        fprintf(stderr, "Testing result: %d/%d\r\n", success_cmd, total_cmd);
        fflush(stderr);
    }
}

bool MainWindow::test_transfer()
{
    test_transfer_request_t test_transfer_request;
    unsigned char len = randBetween(1, 128);

    test_transfer_request.len = len;
    for(uint8_t i = 0; i<len; i++){
        test_transfer_request.data[i] = randBetween(0, 255);
    }

    QByteArray request = createRequest(TYPE_REQUEST, 0, CMD_TEST_TRANSFER,
                                       (unsigned char*)&test_transfer_request,
                                       len + 1);
    QByteArray respond = transaction(request, 1000);

    if(!respond.isEmpty()){
        serial_command * cmd_respond = (serial_command*)respond.data();
        test_transfer_respond_t *pl = (test_transfer_respond_t*)(cmd_respond->payload);

        if(pl->status != STATUS_SUCCESS) return false;
        for(uint8_t i = 0; i<len; i++){
            if(pl->data[i] != test_transfer_request.data[i]){
                return false;
            }
        }

        return true;
    }

    return false;
}

void MainWindow::on_timerTestTransfer_timeout()
{
    total_cmd++;
    if(test_transfer()){
        success_cmd++;
    }
}

int MainWindow::randBetween(int low, int high)
{
    return qrand() % ((high + 1) - low) + low;
}



void MainWindow::on_pushButtonUpgradeFirmware_clicked()
{
    // Doc file hex
    QString filePath = QFileDialog::getOpenFileName(this,
        tr("Open Hex File"), QApplication::applicationDirPath(),
        tr("Hex file (*.hex)"));

    if(filePath.isEmpty())  return;

    qDebug()<<filePath;

    QByteArray hexData;
    intelhex ihFile = readHexFile(filePath);
    if(!ihFile.empty()){
        hexData = getDataOfHexFile(ihFile);
        printBuffer8("Hex file contents", hexData);
    }else{
        return;
    }

    // Gui lenh upgrade start
    if(!upgrade_start()){
        qDebug()<<"Upgrade start command is failed!";
        return;
    }

    sleep(3);

    // Gui file hex - gui tung page
    QByteArray request;
    uint16_t nPage = hexData.length() / 128 + (hexData.length() % 128 != 0);
    for(uint16_t page = 0; page < nPage; page++){
        request.clear();
        request.append(hexData.mid(page*128, 128));
        request.append(132 - request.length(),0xFF);
        if(!upgrade_page(page, (unsigned char *)request.data())){
            qDebug()<<"Upgrade page command is failed!";
            return;
        }
    }

    //sleep(1);

    // Gui lenh upgrade finish
    if(!upgrade_finish()){
        qDebug()<<"Upgrade finish command is failed!";
        return;
    }
}

bool MainWindow::upgrade_start()
{
    upgrade_start_respond_t *pl;

    QByteArray request = createRequest(TYPE_REQUEST, 0, CMD_UPGRADE_START, NULL, 0);
    QByteArray respond = transaction(request, 1000);

    if(!respond.isEmpty()){
        serial_command * cmd_respond = (serial_command*)respond.data();
        pl = (upgrade_start_respond_t*)(cmd_respond->payload);

        if(pl->status == STATUS_SUCCESS){
            return true;
        }
    }

    return false;
}

bool MainWindow::upgrade_page(unsigned char page, unsigned char *page_data)
{
    upgrade_page_request_t rq;
    upgrade_page_respond_t *pl;

    rq.page = page;
    memcpy(rq.page_data, page_data, sizeof(rq.page_data));

    QByteArray request = createRequest(TYPE_REQUEST, 0, CMD_UPGRADE_PAGE, (unsigned char*)&rq, sizeof(rq));
    QByteArray respond = transaction(request, 1000);

    if(!respond.isEmpty()){
        serial_command * cmd_respond = (serial_command*)respond.data();
        pl = (upgrade_page_respond_t*)(cmd_respond->payload);

        if(pl->status == STATUS_SUCCESS){
            return true;
        }
    }

    return false;
}

bool MainWindow::upgrade_finish()
{
    upgrade_finish_respond_t *pl;

    QByteArray request = createRequest(TYPE_REQUEST, 0, CMD_UPGRADE_FINISH, NULL, 0);
    QByteArray respond = transaction(request, 1000);

    if(!respond.isEmpty()){
        serial_command * cmd_respond = (serial_command*)respond.data();
        pl = (upgrade_finish_respond_t*)(cmd_respond->payload);

        if(pl->status == STATUS_SUCCESS){
            return true;
        }
    }

    return false;
}

void MainWindow::on_pushButtonStartApp_clicked()
{
    upgrade_finish();
}
