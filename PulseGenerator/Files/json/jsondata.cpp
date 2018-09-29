#include "jsondata.h"
#include "qjson/parser.h"
#include "qjson/serializer.h"
//#include "qlogger.h"
//#include "define.h"
//using namespace QLogger;

JsonData::JsonData()
{
    this->result = false;
}

JsonData::~JsonData()
{
}

QByteArray JsonData::encodeJsonString(QVariant encodeMap)
{
    QJson::Serializer serializer;
    QByteArray json = serializer.serialize(encodeMap, &this->result);
    this->errMsg = serializer.errorMessage();
    return json;
}

QVariant JsonData::decodeJsonString(QByteArray jsonString)
{
    QJson::Parser parser;
    return parser.parse (jsonString, &this->result);
}
