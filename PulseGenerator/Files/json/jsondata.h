#ifndef JSONDATA_H
#define JSONDATA_H

#include <QString>
#include <QByteArray>
#include <QVariantMap>
class JsonData
{
public:
    JsonData();
    ~JsonData();
    bool result;
    QString errMsg;
    QByteArray encodeJsonString(QVariant encodeMap);
    QVariant decodeJsonString(QByteArray jsonString);
};

#endif // JSONDATA_H
