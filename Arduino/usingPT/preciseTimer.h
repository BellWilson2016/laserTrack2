#ifndef PRECISETIMER_H
#define PRECISETIMER_H

#define DACPINON     PORTD |= B00010000
#define DACPINOFF    PORTD &= B11101111
#define SERIALPINON  PORTD |= B00001000
#define SERIALPINOFF PORTD &= B11110111
#define LASERPINON   PORTD |= B00100000
#define LASERPINOFF  PORTD &= B11011111

#include "Arduino.h"
#include <inttypes.h>

typedef void (*function)();
typedef void (*errorFunction)(int);
typedef unsigned char byte;

class preciseTimer {
  public:
    preciseTimer();
    void addInterrupt(volatile unsigned char * interrupt, byte intBit);
    void queueNextEvent(unsigned long eventDelay, function scheduleFcn);
    void start();
    void clearQueue();
    void restoreInterrupts();
    void setInterruptBlockTime(unsigned long blockTime);
    void setErrorFcn(errorFunction anErrorFcn);
    void prepareForEvent();
    unsigned int  timerOverflows;
    bool isrRunning;
  private: 

    volatile unsigned char * interruptRegList[];
    byte interruptBitList[];
    byte interruptStates[];
    byte numInterrupts;
    void nullFcn();
    void nullErrorFcn(int errorNum);  
    unsigned long eventTime;
    function eventFcn;
    errorFunction errorFcn;
    unsigned long interruptBlockTime;
    
       
};

extern preciseTimer pT;

#endif
