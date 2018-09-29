#include "wav.h"
#include <qendian.h>
#include <QVector>
#include <QDebug>
#include "utils.h"

QString us2DurationStr(int64_t us){
    unsigned short hour, minute, second, milisecond;

    hour = us / 3600000000;
    minute = us % 3600000000 / 60000000;
    second = us % 60000000 / 1000000;
    milisecond = us % 1000000 / 1000;

    char tmp[13];
    sprintf(tmp,"%02d:%02d:%02d.%03d",hour, minute, second, milisecond);
    return QString(tmp);
}

Wav::Wav(QObject *parent)
    : QFile(parent), m_headerLength(0)
{

}

int Wav::getHeaderLength()
{
    return m_headerLength;
}

int Wav::getDataLength()
{
    return size() - m_headerLength;
}

QAudioFormat &Wav::getFormat()
{
    return m_fileFormat;
}

bool Wav::open(const QString &fileName)
{
    close();
    setFileName(fileName);
    bool rs = QFile::open(QIODevice::ReadOnly) && readHeader();
    print_properties();
    return rs;
}

QVector<float> Wav::read(uint8_t channel, int offset, int len)
{
    QVector <float> vout;
    short *val;

    char *frame = (char*)malloc(m_fileFormat.bytesPerFrame());
    if(frame == NULL) return vout;

    uint8_t sampleOffset = channel*m_fileFormat.bytesPerFrame()/m_fileFormat.channelCount();
    float normalizeRatio = (1 << m_fileFormat.sampleSize());
    if(m_fileFormat.sampleType() == QAudioFormat::SignedInt){
        normalizeRatio = normalizeRatio / 2;
    }

    seek(m_headerLength + offset*m_fileFormat.bytesPerFrame());
    int i = 0;
    while(!atEnd()){
        if(i==len)  break;
        QIODevice::read(frame, m_fileFormat.bytesPerFrame());
        val = (short*)(frame + sampleOffset);
        vout << *val/normalizeRatio;
        i++;
    }

    free(frame);

    return vout;
}

QVector<float> Wav::read( uint8_t channel)
{
    QVector<float> vout;
    short *val;
    char *frame = (char*)malloc(m_fileFormat.bytesPerFrame());
    if(frame == NULL) return vout;

    uint8_t sampleOffset = channel*m_fileFormat.bytesPerFrame()/m_fileFormat.channelCount();
    float normalizeRatio = 1 << m_fileFormat.sampleSize();
    if(m_fileFormat.sampleType() == QAudioFormat::SignedInt){
        normalizeRatio = normalizeRatio / 2;
    }

    seek(m_headerLength);
    int i = 0;
    while(!atEnd()){
        QIODevice::read(frame, m_fileFormat.bytesPerFrame());
        val = (short*)(frame  + sampleOffset);
        vout << *val/normalizeRatio;
        i++;
    }

    free(frame);

    return vout;
}

int Wav::read(float *buffer, uint8_t channel, int offset, int len)
{
    short *val;

    char *frame = (char*)malloc(m_fileFormat.bytesPerFrame());
    if(frame == NULL) return -1;

    uint8_t sampleOffset = channel*m_fileFormat.bytesPerFrame()/m_fileFormat.channelCount();
    float normalizeRatio = (1 << m_fileFormat.sampleSize());
    if(m_fileFormat.sampleType() == QAudioFormat::SignedInt){
        normalizeRatio = normalizeRatio / 2;
    }
    // qDebug()<<"normalizeRatio"<<normalizeRatio;

    seek(m_headerLength + offset*m_fileFormat.bytesPerFrame());
    int i = 0;
    while(!atEnd()){
        QIODevice::read(frame, m_fileFormat.bytesPerFrame());
        val = (short*)(frame + sampleOffset);
        buffer[i++] = *val/normalizeRatio;
        if(i==len)  break;
    }

    free(frame);

    return i;
}

int Wav::read(float *buffer, uint8_t channel)
{
    short *val;
    char *frame = (char*)malloc(m_fileFormat.bytesPerFrame());
    if(frame == NULL) return -1;

    uint8_t sampleOffset = channel*m_fileFormat.bytesPerFrame()/m_fileFormat.channelCount();
    float normalizeRatio = 1 << m_fileFormat.sampleSize();
    if(m_fileFormat.sampleType() == QAudioFormat::SignedInt){
        normalizeRatio = normalizeRatio / 2;
    }
    //qDebug()<<"normalizeRatio"<<normalizeRatio;

    seek(m_headerLength);
    int i = 0;
    while(!atEnd()){
        QIODevice::read(frame, m_fileFormat.bytesPerFrame());
        val = (short*)(frame  + sampleOffset);
        buffer[i++] = *val/normalizeRatio;
    }

    free(frame);

    return i;
}

int Wav::read(double *buffer, uint8_t channel, int offset, int len)
{
    short *val;

    char *frame = (char*)malloc(m_fileFormat.bytesPerFrame());
    if(frame == NULL) return -1;

    uint8_t sampleOffset = channel*m_fileFormat.bytesPerFrame()/m_fileFormat.channelCount();
    double normalizeRatio = (1 << m_fileFormat.sampleSize());
    if(m_fileFormat.sampleType() == QAudioFormat::SignedInt){
        normalizeRatio = normalizeRatio / 2;
    }
    //qDebug()<<"normalizeRatio"<<normalizeRatio;

    seek(m_headerLength + offset*m_fileFormat.bytesPerFrame());
    int i = 0;
    while(!atEnd()){
        QIODevice::read(frame, m_fileFormat.bytesPerFrame());
        val = (short*)(frame + sampleOffset);
        buffer[i++] = *val/normalizeRatio;
        if(i==len)  break;
    }

    free(frame);

    return i;
}

int Wav::read(double *buffer, uint8_t channel)
{
    short *val;
    char *frame = (char*)malloc(m_fileFormat.bytesPerFrame());
    if(frame == NULL) return -1;

    uint8_t sampleOffset = channel*m_fileFormat.bytesPerFrame()/m_fileFormat.channelCount();
    double normalizeRatio = 1 << m_fileFormat.sampleSize();
    if(m_fileFormat.sampleType() == QAudioFormat::SignedInt){
        normalizeRatio = normalizeRatio / 2;
    }
    //qDebug()<<"normalizeRatio"<<normalizeRatio;

    seek(m_headerLength);
    int i = 0;
    while(!atEnd()){
        QIODevice::read(frame, m_fileFormat.bytesPerFrame());
        val = (short*)(frame  + sampleOffset);
        buffer[i++] = *val/normalizeRatio;
    }

    free(frame);

    return i;
}

void Wav::print_properties()
{
    qDebug()<<"Properties of file"<<this->fileName();
    qDebug()<<"   Location:"<<QFileInfo(this->fileName()).absolutePath();
    qDebug()<<"   Size:"<<this->size();
    qDebug()<<"   Duration:" << qPrintable(us2DurationStr(m_fileFormat.durationForBytes(this->getDataLength())));
    qDebug()<<"   Channels:" << m_fileFormat.channelCount();
    qDebug()<<"   Bytes Per Frame:"<< m_fileFormat.bytesPerFrame();
    qDebug()<<"   Format:"<<m_fileFormat.codec();
    qDebug()<<"      Sample Rate:" << m_fileFormat.sampleRate();
    qDebug()<<"      Sample Size:" << m_fileFormat.sampleSize();
    qDebug()<<"      Sample Type:" << m_fileFormat.sampleType();
    qDebug()<<"      Byte Order:" << m_fileFormat.byteOrder();
}

bool Wav::readHeader(){
    seek(0);
    WavCombinedHeader header;
    bool result = QIODevice::read(reinterpret_cast<char *>(&header), sizeof(WavCombinedHeader)) == sizeof(WavCombinedHeader);
    if (result) {
        if ((memcmp(&header.riff.descriptor.id, "RIFF", 4) == 0
            || memcmp(&header.riff.descriptor.id, "RIFX", 4) == 0)
            && memcmp(&header.riff.type, "WAVE", 4) == 0
            && memcmp(&header.wave.descriptor.id, "fmt ", 4) == 0
            && (header.wave.audioFormat == 1 || header.wave.audioFormat == 0)) {

            // Read off remaining header information
            WavDataHeader dataHeader;

            if (qFromLittleEndian<uint32_t>(header.wave.descriptor.size) > sizeof(WavHeader)) {
                // Extended data available
                uint16_t extraFormatBytes;
                if (peek((char*)&extraFormatBytes, sizeof(uint16_t)) != sizeof(uint16_t))
                    return false;
                const int64_t throwAwayBytes = sizeof(uint16_t) + qFromLittleEndian<uint16_t>(extraFormatBytes);
                if (QIODevice::read(throwAwayBytes).size() != throwAwayBytes)
                    return false;
            }

            if (QIODevice::read((char*)&dataHeader, sizeof(WavDataHeader)) != sizeof(WavDataHeader))
                return false;

            // Establish format
            if (memcmp(&header.riff.descriptor.id, "RIFF", 4) == 0)
                m_fileFormat.setByteOrder(QAudioFormat::LittleEndian);
            else
                m_fileFormat.setByteOrder(QAudioFormat::BigEndian);

            int bps = qFromLittleEndian<uint16_t>(header.wave.bitsPerSample);
            m_fileFormat.setChannelCount(qFromLittleEndian<uint16_t>(header.wave.numChannels));
            m_fileFormat.setCodec("audio/pcm");
            m_fileFormat.setSampleRate(qFromLittleEndian<uint32_t>(header.wave.sampleRate));
            m_fileFormat.setSampleSize(qFromLittleEndian<uint16_t>(header.wave.bitsPerSample));
            m_fileFormat.setSampleType(bps == 8 ? QAudioFormat::UnSignedInt : QAudioFormat::SignedInt);
        } else {
            result = false;
        }
    }
    m_headerLength = pos();
    return result;
}

/********************************************************************************
 * Util functions
 * ******************************************************************************/
qint64 audioDuration(const QAudioFormat &format, qint64 bytes){
    return (bytes * 1000000) /
        (format.sampleRate() * format.channelCount() * (format.sampleSize() / 8));
}

qint64 audioLength(const QAudioFormat &format, qint64 microSeconds){
   qint64 result = (format.sampleRate() * format.channelCount() * (format.sampleSize() / 8))
       * microSeconds / 1000000;
   result -= result % (format.channelCount() * format.sampleSize());
   return result;
}

qreal nyquistFrequency(const QAudioFormat &format){
    return format.sampleRate() / 2;
}

QString formatToString(const QAudioFormat &format){
    QString result;

    if (QAudioFormat() != format) {
        if (format.codec() == "audio/pcm") {
            Q_ASSERT(format.sampleType() == QAudioFormat::SignedInt);

            const QString formatEndian = (format.byteOrder() == QAudioFormat::LittleEndian)
                ?   QString("LE") : QString("BE");

            QString formatType;
            switch (format.sampleType()) {
            case QAudioFormat::SignedInt:
                formatType = "signed";
                break;
            case QAudioFormat::UnSignedInt:
                formatType = "unsigned";
                break;
            case QAudioFormat::Float:
                formatType = "float";
                break;
            case QAudioFormat::Unknown:
                formatType = "unknown";
                break;
            }

            QString formatChannels = QString("%1 channels").arg(format.channelCount());
            switch (format.channelCount()) {
            case 1:
                formatChannels = "mono";
                break;
            case 2:
                formatChannels = "stereo";
                break;
            }

            result = QString("%1 Hz %2 bit %3 %4 %5")
                .arg(format.sampleRate())
                .arg(format.sampleSize())
                .arg(formatType)
                .arg(formatEndian)
                .arg(formatChannels);
        } else {
            result = format.codec();
        }
    }

    return result;
}

bool isPCM(const QAudioFormat &format){
    return (format.codec() == "audio/pcm");
}


bool isPCMS16LE(const QAudioFormat &format){
    return isPCM(format) &&
           format.sampleType() == QAudioFormat::SignedInt &&
           format.sampleSize() == 16 &&
           format.byteOrder() == QAudioFormat::LittleEndian;
}

const qint16  PCMS16MaxValue     =  32767;
const quint16 PCMS16MaxAmplitude =  32768; // because minimum is -32768

qreal pcmToReal(qint16 pcm){
    return qreal(pcm) / PCMS16MaxAmplitude;
}

qint16 realToPcm(qreal real){
    return real * PCMS16MaxValue;
}
