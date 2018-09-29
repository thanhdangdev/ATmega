#ifndef FILE_UTILS_H
#define FILE_UTILS_H

#include <QByteArray>
#include <QString>

long getFileSize_C(char *filename);
long getFileSize_Qt(const QString &fileName);
long getFileSizeOpening_C(FILE *fp);

bool cvt_HexFile2BinFile(const QString &hexFilePath, const QString &binFilePath);
bool cvt_HexFile2BinFileWithCrc32(const QString &hexFilePath, const QString &binFilePath);
bool cvt_RomFile2BinFile(const QString &romFilePath, const QString &binFilePath);
bool cvt_RomFile2BinFileWithCrc32(const QString &romFilePath, const QString &binFilePath);

#endif // FILE_UTILS_H
