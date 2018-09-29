#include "file_utils.h"
#include "Files/ihex/ihex_utils.h"
#include "Files/bin/bin.h"
#include "Files/rom/rom.h"
#include "Cryptographic/checksum.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QFileInfo>
#include <sys/stat.h>

/* Get a file size
 *
 */
long getFileSize_C(char *filename)
{
    struct stat stat_buf;
    int rc = stat(filename, &stat_buf);
    return rc == 0 ? stat_buf.st_size : -1;
}

long getFileSize_Qt(const QString &fileName)
{
    return QFileInfo(fileName).size();
}

/* Get a file is already opening size
 *
 */
long getFileSizeOpening_C(FILE *fp){
    fprintf(stderr, "TDDB: getFileSizeOpening error\r\n");
    long prev=ftell(fp);
    fseek(fp, 0L, SEEK_END);
    long sz=ftell(fp);
    //go back to where we were
    fseek(fp,prev,SEEK_SET);
    return sz;
}

bool cvt_HexFile2BinFile(const QString &hexFilePath, const QString &binFilePath)
{
    bool rs = false;
    intelhex ihFile = readHexFile(hexFilePath);
    if(!ihFile.empty())
    {
        QByteArray dat;
        dat = getDataOfHexFile(ihFile);
        if(writeBinFile(binFilePath, dat))
        {
            qDebug()<<"cvt_HexFile2BinFile func info: Convertion success.";
            rs = true;
        }
    }
    else
    {
        qDebug()<<"cvt_HexFile2BinFile func err: Convertion Failed.";
    }

    return rs;
}

bool cvt_HexFile2BinFileWithCrc32(const QString &hexFilePath, const QString &binFilePath)
{
    bool rs = false;
    intelhex ihFile = readHexFile(hexFilePath);
    if(!ihFile.empty())
    {
        QByteArray dat;
        dat = getDataOfHexFile(ihFile);

        // Calc crc32 and attach it (Little Endian)
        uint32_t crc = crc32((unsigned char*)dat.data(),dat.length());
        dat.append(crc       & 0x000000FF);
        dat.append((crc >> 8) & 0x000000FF);
        dat.append((crc >> 16)& 0x000000FF);
        dat.append( crc >> 24);

        if(writeBinFile(binFilePath, dat))
        {
            qDebug()<<"cvt_HexFile2BinFileWithCrc32 func info: Convertion success.";
            rs = true;
        }
    }
    else
    {
        qDebug()<<"cvt_HexFile2BinFile func err: Convertion Failed.";
    }
    return rs;
}
