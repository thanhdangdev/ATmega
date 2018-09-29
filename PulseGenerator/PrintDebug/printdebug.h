#ifndef PRINTDEBUG_H	// Print Debug
#define PRINTDEBUG_H

#include <QDebug>
#include <stdio.h>

#ifndef LITTLE_ENDIAN
#define LITTLE_ENDIAN 1234
#endif

#ifndef BIG_ENDIAN
#define	BIG_ENDIAN	4321
#endif

#ifdef QT_DEBUG
#define printDebug(...) {\
        fprintf(stderr, __VA_ARGS__); \
        fflush(stderr); \
    }
#else
#define printDebug(...)
#endif

class NullDebug
{
public:
    template <typename T>
    NullDebug& operator<<(const T&) { return *this; }
};

inline NullDebug nullDebug() { return NullDebug(); }

//#ifdef LOG_ENGINE
//#   define ENGINE_DEBUG qDebug()
//#else
//#   define ENGINE_DEBUG nullDebug()
//#endif

//#ifdef LOG_SPECTRUMANALYSER
//#   define SPECTRUMANALYSER_DEBUG qDebug()
//#else
//#   define SPECTRUMANALYSER_DEBUG nullDebug()
//#endif

//#ifdef LOG_WAVEFORM
//#   define WAVEFORM_DEBUG qDebug()
//#else
//#   define WAVEFORM_DEBUG nullDebug()
//#endif

/********************************************************************************
 * Print debug function
 * ******************************************************************************/
bool isPrintable(char character);
void printBuffer8(unsigned char *buffer, unsigned int len);
void printBuffer8(QByteArray buffer);
void printBuffer8(const QString &msg, unsigned char *buffer, unsigned int len);
void printBuffer8(const QString &msg, QByteArray buffer);

void printBuffer16(int16_t *buffer, unsigned int len);
void printBuffer16(int16_t *buffer, unsigned int offset, unsigned int len);
void printBuffer16(char *buffer, unsigned int len, int endian);
void printBuffer16(char *buffer, unsigned int offset, unsigned int len, int endian);
void printBuffer32(int32_t *buffer, unsigned int offset, unsigned int len);
void printBuffer32(char *buffer, unsigned int len, int endian);
void printBuffer32(char *buffer, unsigned int offset, unsigned int len, int endian);

void printBufferDouble(double *buffer, unsigned int len);
void printBufferFloat(float *buffer, unsigned int len);
void printBufferFloat(QVector<float> buffer);


#endif // PDEBUG_H
