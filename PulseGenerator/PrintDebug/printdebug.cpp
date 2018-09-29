#include "printdebug.h"

/********************************************************************************
 * Print debug function
 * ******************************************************************************/
bool isPrintable(char character){
    if (character >= ' ' && character <= '~'){
        return true;
    }

    return false;
}

void printBuffer8(unsigned char *buffer, unsigned int len)
{
    fprintf(stderr, "\r\n------------------------------------------------------------------------\r\n");
    fprintf(stderr, " Offset  |");
    for (uint8_t i = 0x00; i <= 0x0F; i++){
        if ((i % 8 == 0) && (i != 0))  fprintf(stderr, " ");
        fprintf(stderr, "%X  ", i);
    }
    fprintf(stderr, "\r\n------------------------------------------------------------------------");

    uint32_t addr = 0;

    uint32_t sec_cnt = 0;
    for (uint32_t i = 0; i < len; i++){
        if(i % 16 == 0){
            fprintf(stderr, "\r\n%08X |", addr);
            addr += 16;
        }else if(i % 8 == 0) fprintf(stderr, " ");

        fprintf(stderr, "%02X ", buffer[i]);

        if((i + 1) % 16 == 0){
            fprintf(stderr, "| ");
            uint32_t idx = 16;
            for (uint32_t j = 1; j <= 16; j++){
                uint8_t c = buffer[i + 1 - idx--];
                if (c >= 33 && c <= 126) {
                    fprintf(stderr, "%c", c);
                }else {
                    fprintf(stderr, ".");
                }
            }

            if (i % 512 == 0){
                fprintf(stderr, "\r\nSector %d\r\n", ++sec_cnt);
            }
        }
    }

    uint8_t remain = len % 16;
    if(remain){
        for(uint8_t k = remain; k < 16; k++){
            if(k && k % 8 == 0)   fprintf(stderr," ");
            fprintf(stderr, "   ");
        }

        fprintf(stderr, "| ");
        for (uint32_t j = 0; j < remain; j++)
        {
            uint8_t c = buffer[len - remain + j];
            if (c >= 33 && c <= 126)
            {
                fprintf(stderr, "%c", c);
            }
            else
            {
                fprintf(stderr, ".");
            }
        }
    }

    fprintf(stderr, "\r\n\r\n");
    fflush(stderr);
}

void printBuffer8(QByteArray buffer){
    printBuffer8((unsigned char*)buffer.data(), buffer.length());
}

void printBuffer8(const QString &msg, unsigned char *buffer, unsigned int len){
    fprintf(stderr, "%s\r\n", msg.toLatin1().data());
    printBuffer8(buffer, len);
}

void printBuffer8(const QString &msg, QByteArray buffer){
    printBuffer8(msg, (unsigned char*)buffer.data(), buffer.size());
}

void printBuffer16(int16_t *buffer, unsigned int len)
{
    unsigned int i, j;

    fprintf(stderr,"size %d word(s) = %d byte(s):\n", len,len*2);

    for (i = 0; i < len; i++)
    {
        fprintf(stderr,"%04X ", (int)(buffer[i]&0xffff));
        if (((i + 1) % 8 == 0) || (i == len - 1))
        {
            for (j = 0; j < 12 - (i % 8); j++)
            {
                if((i == len - 1) && ((i+1)%8) > 0 && j<(8-((i+1)%8)))
                {
                    fprintf(stderr,"    ");
                }
            }

            fprintf(stderr,"   |  ");

            for (j = i - (i % 8); j <= i; j++)
            {
                if (isPrintable((char) (buffer[j]>>8)) )
                {
                    fprintf(stderr,"%c", (char) (buffer[j]>>8));
                }
                else
                {
                    fprintf(stderr,".");
                }

                if (isPrintable((char) (buffer[j])))
                {
                    fprintf(stderr,"%c", (char) (buffer[j]));
                }
                else
                {
                    fprintf(stderr,".");
                }
            }
            fprintf(stderr,"\r\n");
        }
    }
}

void printBuffer16(int16_t *buffer, unsigned int offset, unsigned int len)
{
    printBuffer16((buffer+offset),len);
}

void printBuffer16(char *buffer, unsigned int len, int endian)
{
    unsigned int i, j;

    fprintf(stderr,"size %d word(s) = %d byte(s):\n", len, len*2);

    for (i = 0; i < len; i+=2)
    {
        if(endian==LITTLE_ENDIAN)
        {
            fprintf(stderr,"%02X", (int)buffer[i]&0xff);
            fprintf(stderr,"%02X", (int)buffer[i+1]&0xff);
        }
        else
        {
            fprintf(stderr,"%02X", (int)buffer[i+1]&0xff);
            fprintf(stderr,"%02X", (int)buffer[i]&0xff);
        }
        fprintf(stderr," ");

        if (((i + 2) % 16 == 0) || (i >= len - 2))
        {
            for (j = 0; j < 16 - (i % 16); j+=2)
            {
                if((i >= len - 2) && ((i+2)%16) > 0 && j<(16-((i+2)%16)))
                {
                    fprintf(stderr,"     ");
                }
            }

            fprintf(stderr,"   |  ");

            for (j = i - (i % 16); j <= i; j+=2)
            {
                if(endian==LITTLE_ENDIAN)
                {
                    if (isPrintable((char) (buffer[j])) )
                    {
                        fprintf(stderr,"%c", (char) (buffer[j]));
                    }
                    else
                    {
                        fprintf(stderr,".");
                    }

                    if (isPrintable((char) (buffer[j+1])))
                    {
                        fprintf(stderr,"%c", (char) (buffer[j+1]));
                    }
                    else
                    {
                        fprintf(stderr,".");
                    }
                }
                else
                {
                    if (isPrintable((char) (buffer[j+1])) )
                    {
                        fprintf(stderr,"%c", (char) (buffer[j+1]));
                    }
                    else
                    {
                        fprintf(stderr,".");
                    }

                    if (isPrintable((char) (buffer[j])))
                    {
                        fprintf(stderr,"%c", (char) (buffer[j]));
                    }
                    else
                    {
                        fprintf(stderr,".");
                    }
                }
            }
            fprintf(stderr,"\r\n");
        }
    }
}

void printBuffer16(char *buffer, unsigned int offset, unsigned int len, int endian)
{
    printBuffer16((buffer+offset), len, endian);
}

void printBuffer32(int32_t *buffer, unsigned int len)
{
    unsigned int i, j, k;

    fprintf(stderr,"size %d dword(s) = %d byte(s):\n", len,len*4);

    for (i = 0; i < len; i++)
    {
        fprintf(stderr,"%08X ", (int)(buffer[i]&0xffffffff));
        if (((i + 1) % 4 == 0) || (i == len - 1))
        {
            for (j = 0; j < 5 - (i % 4); j++)
            {
                if((i == len - 1) && ((i+1)%4) > 0 && j<(4-((i+1)%4)))
                {
                    fprintf(stderr,"         ");
                }
            }

            fprintf(stderr,"   |  ");

            for (j = i - (i % 4); j <= i; j++)
            {
                for(k=0;k<4;k++)
                {
                    if (isPrintable((char) (buffer[j]>>(8*(3-k)))))
                    {
                        fprintf(stderr,"%c", (char) (buffer[j]>>(8*(3-k))));
                    }
                    else
                    {
                        fprintf(stderr,".");
                    }
                }
            }
            fprintf(stderr,"\r\n");
        }
    }
}

void printBuffer32(int32_t *buffer, unsigned int offset, unsigned int len)
{
    printBuffer32(buffer + offset,len);
}

void printBuffer32(char *buffer, unsigned int len, int endian)
{
    unsigned int i, j;
    int k;

    fprintf(stderr,"size %d dword(s) = %d byte(s):\n", len/4,len);

    for (i = 0; i < len; i+=4)
    {
        if(endian==LITTLE_ENDIAN)
        {
            for(k=0;k<4;k++)
            {
                fprintf(stderr,"%02X", (int)(buffer[i+k]&0xff));
            }
        }
        else
        {
            for(k=3;k>=0;k--)
            {
                fprintf(stderr,"%02X", (int)(buffer[i+k]&0xff));
            }
        }

        fprintf(stderr," ");

        if (((i+4) % 16 == 0) || (i>= len - 4))
        {
            for (j = 0; j < 16 - (i % 16); j+=4)
            {
                if((i >= len - 4) && ((i+4)%16) > 0 && j<(16-((i+4)%16)))
                {
                    fprintf(stderr,"         ");
                }
            }

            fprintf(stderr,"   |  ");

            for (j = i - (i % 16); j <= i; j+=4)
            {
                if(endian==LITTLE_ENDIAN)
                {
                    for(k=0;k<4;k++)
                    {
                        if (isPrintable((char) (buffer[j+k])))
                        {
                            fprintf(stderr,"%c", (char) (buffer[j+k]));
                        }
                        else
                        {
                            fprintf(stderr,".");
                        }
                    }
                }
                else
                {
                    for(k=3;k>=0;k--)
                    {
                        if (isPrintable((char) (buffer[j+k])))
                        {
                            fprintf(stderr,"%c", (char) (buffer[j+k]));
                        }
                        else
                        {
                            fprintf(stderr,".");
                        }
                    }
                }
            }
            fprintf(stderr,"\r\n");
        }
    }
}

void printBuffer32(char *buffer, unsigned int offset, unsigned int len, int endian)
{
    printBuffer32(buffer+offset,len,endian);
}

void print_buffer(double *buffer, unsigned int len){
    for(unsigned int i = 0; i<len; i++){
        fprintf(stderr, "%f\r\n", buffer[i]);
    }
    fflush(stderr);
}

void print_buffer(float *buffer, unsigned int len){
    for(unsigned int i = 0; i<len; i++){
        fprintf(stderr, "%f\r\n", buffer[i]);
    }
    fflush(stderr);
}

void print_buffer(QVector<float> buffer){
    for(int i = 0; i<buffer.size(); i++){
        fprintf(stderr, "%d\t%f\r\n", i, buffer[i]);
    }
    fflush(stderr);
}


