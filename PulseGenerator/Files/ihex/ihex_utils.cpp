#include "ihex_utils.h"
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QString>
#include <QDebug>

intelhex readHexFile(const QString &filePath)
{
    intelhex ihFile;
    std::ifstream intelHexInput;

    intelHexInput.open(filePath.toLatin1().data(), ifstream::in);
    if(!intelHexInput.good())
    {
        fprintf(stderr,"ReadHexFile func err: Can't read file %s.\n", filePath.toLatin1().data());
        fflush(stderr);
        return intelhex();
    }

    intelHexInput >> ihFile;

    // Display Warning & Error Message
    if (ihFile.getNoWarnings() < 1 && ihFile.getNoErrors() < 1)
    {
        fprintf(stderr,"ReadHexFile func info: No issues in file.\n");
    }
    else
    {
        QString outputMessage;

        fprintf(stderr,"ReadHexFile func err: Issues found in file.\n");
        outputMessage = QString("File %1 contains the following issues:").arg(filePath);

        if (ihFile.getNoWarnings() > 0)
        {
            outputMessage += "\n";

            while(ihFile.getNoWarnings() > 0)
            {
                QString qmessage;
                string message;

                ihFile.popNextWarning(message);

                qmessage = QString::fromStdString(message);

                outputMessage += "WARNING: ";
                outputMessage += qmessage;
                outputMessage += "\n";
            }
        }
        if (ihFile.getNoErrors() > 0)
        {
            outputMessage += "\n";

            while (ihFile.getNoErrors() > 0)
            {
                QString qmessage;
                string message;

                ihFile.popNextError(message);

                qmessage = QString::fromStdString(message);

                outputMessage += "ERROR: " + qmessage + "\n";
            }
        }

        fprintf(stderr,"%s\n",outputMessage.toLatin1().data());
    }

    return ihFile;
}

QByteArray getDataOfHexFile(intelhex ihFile, int64_t beginAddress, int64_t len)
{
    QByteArray dat;

    ihFile.begin();
    uint32_t add = ihFile.currentAddress();

    if(beginAddress !=-1 && beginAddress<add){
        fprintf(stderr, "GetDataOfHexFile func err: Begin Address too small\r\n");
        fflush(stderr);
    }else{
        add = (beginAddress==-1 ? ihFile.currentAddress() : (uint32_t)(beginAddress&0x00000000FFFFFFFF));
        while(!ihFile.endOfData()){
            unsigned char b = 0;
            ihFile.getData(&b,add);
            dat.append(b);
            add++;

            if(len!=-1){
                if(--len==0)    break;
            }
        }
    }

    return dat;
}
