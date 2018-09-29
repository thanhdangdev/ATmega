#ifndef WAV_H
#define WAV_H

#include <QObject>
#include <QFile>
#include <QFileInfo>
#include <QAudioFormat>
#include <stdint.h>

struct WavChunk{
    char        id[4];
    uint32_t    size;
};

struct WavRiffHeader{
    WavChunk    descriptor;     // "RIFF"
    char        type[4];        // "WAVE"
};

struct WavHeader{
    WavChunk    descriptor;
    uint16_t    audioFormat;
    uint16_t    numChannels;
    uint32_t    sampleRate;
    uint32_t    byteRate;
    uint16_t    blockAlign;
    uint16_t    bitsPerSample;
};

struct WavDataHeader{
    WavChunk        descriptor;
};

struct WavCombinedHeader{
    WavRiffHeader   riff;
	WavHeader       wave;
};


class Wav : public QFile
{
    Q_OBJECT
public:
    Wav(QObject *parent = 0);

    //using QFile::open;
    int getLength();
    int getHeaderLength();
    int getDataLength();
    int getFs();
    QAudioFormat &getFormat();

    bool open(const QString &fileName);

    QVector<float> read(uint8_t channel, int offset, int len);
    QVector<float> read(uint8_t channel);
    int read(float * buffer, uint8_t channel, int offset, int len);
    int read(float * buffer, uint8_t channel);
    int read(double * buffer, uint8_t channel, int offset, int len);
    int read(double * buffer, uint8_t channel);

    void print_properties();

private:
    bool readHeader();

signals:

public slots:

private:
    QAudioFormat m_fileFormat;
    int64_t m_headerLength;
};

/********************************************************************************
 * Util functions
 * ******************************************************************************/
qint64 audioDuration(const QAudioFormat &format, qint64 bytes);
qint64 audioLength(const QAudioFormat &format, qint64 microSeconds);
QString formatToString(const QAudioFormat &format);
qreal nyquistFrequency(const QAudioFormat &format);

// Scale PCM value to [-1.0, 1.0]
qreal pcmToReal(qint16 pcm);

// Scale real value in [-1.0, 1.0] to PCM
qint16 realToPcm(qreal real);

// Check whether the audio format is PCM
bool isPCM(const QAudioFormat &format);

// Check whether the audio format is signed, little-endian, 16-bit PCM
bool isPCMS16LE(const QAudioFormat &format);


#endif // WAV_H
