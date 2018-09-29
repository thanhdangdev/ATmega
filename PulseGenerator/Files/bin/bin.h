#ifndef BIN_H
#define BIN_H

#include <QByteArray>
#include <QString>

QByteArray readBinFile(const QString &filePath);
QByteArray readBinFile(const QString &filePath, int offset, int len);
QByteArray readBinFile(const QString &filePath, int len);
int readBinFile(const QString &filePath, char * buffer, int offset, int len);
bool writeBinFile(const QString &filePath, QByteArray dat);
bool appendBinFile(const QString &filePath, QByteArray dat);

#endif // BIN_H

