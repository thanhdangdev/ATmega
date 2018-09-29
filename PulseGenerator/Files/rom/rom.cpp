#include "rom.h"
#include <QFile>
#include <QTextStream>
#include <stdio.h>

QByteArray readRomFile(const QString &filePath)
{
    QByteArray rs;
    QFile file(filePath);
    QTextStream textStream(&file);

    if(!file.open(QIODevice::Text | QIODevice::ReadOnly))
    {
        fprintf(stderr, "readRomFile func error: Can't read file %s", filePath.toLatin1().data());
        fflush(stderr);
    }
    else
    {
        while(!textStream.atEnd())
        {
            QString line = textStream.readLine();
            QStringList lst = line.split(':');
            unsigned short dat = lst.at(1).toUShort(NULL,16);
            rs.append(dat & 0x00FF);
            rs.append(dat>>8);
        }
    }

    return rs;
}
