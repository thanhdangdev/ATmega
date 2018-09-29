#ifndef IHEX_UTILS_H
#define IHEX_UTILS_H

#include "intelhexclass.h"
#include <QByteArray>

intelhex readHexFile(const QString &filePath);
QByteArray getDataOfHexFile(intelhex ihFile, int64_t beginAddress = -1, int64_t len = -1);


#endif // IHEX_UTILS_H

