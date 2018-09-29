#include "bin.h"
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>

/* Read a bin file on disk into a byte array
 *
 * Function name: ReadBinFile
 *   Create date: Oct 08, 2015
 * Modified date:
 *        Return:
 *    Parameters:
 *    Limitation:
 */
QByteArray readBinFile(const QString &filePath)
{
    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly))
    {
        fprintf(stderr, "ReadBinFile func err: Can't open file %s!\n", filePath.toLatin1().data());
        return QByteArray();
    }
    QByteArray dat = file.readAll();
    file.close();

    return dat;
}

QByteArray readBinFile(const QString &filePath, int offset, int len)
{
    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly))
    {
        fprintf(stderr, "ReadBinFile func err: Can't open file %s!\n", filePath.toLatin1().data());
        return QByteArray();
    }

    if(!file.seek(offset))
    {
        fprintf(stderr, "ReadBinFile func err: Seek out of file length!\n");
        return QByteArray();
    }
    QByteArray dat = file.read(len);
    file.close();

    return dat;
}

QByteArray readBinFile(const QString &filePath, int len)
{
    return readBinFile(filePath, 0, len);
}

int readBinFile(const QString &filePath, char * buffer, int offset, int len)
{
    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly))
    {
        fprintf(stderr, "ReadBinFile func err: Can't open file %s!\n", filePath.toLatin1().data());
        return -1;
    }

    if(!file.seek(offset))
    {
        fprintf(stderr, "ReadBinFile func err: Seek out of file length!\n");
        file.close();
        return -1;
    }

    int l = file.read(buffer,len);
    file.close();

    return l;
}

bool writeBinFile(const QString &filePath, QByteArray dat)
{
    bool rs = false;

    QFile file(filePath);

    if(!file.open(QIODevice::WriteOnly))
    {
        fprintf(stderr, "WriteBinFile func err: Can't open file %s!\n", filePath.toLatin1().data());
    }
    else if(file.write(dat.data(),dat.length())==dat.length())
    {
        //qDebug()<<"WriteBinFile func info: Write bin file success.";
        rs = true;
    }

    return rs;
}

bool appendBinFile(const QString &filePath, QByteArray dat)
{
    bool rs = false;

    QFile file(filePath);

    if(!file.open(QIODevice::ReadWrite|QIODevice::Append))
    {
        fprintf(stderr, "AppendBinFile func err: Can't open file %s!\n", filePath.toLatin1().data());
    }
    else if(file.write(dat.data(),dat.length())==dat.length())
    {
        file.close();
        rs = true;
    }

    return rs;
}
