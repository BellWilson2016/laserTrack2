#ifndef PRECISETIMER_H
#define PRECISETIMER_H

#define MAXINTREG   20
#define PREEVENTPAD (40ul << 4)

#include "Arduino.h"
#include <inttypes.h>

typedef void (*function)();
typedef unsigned char byte;
typedef volatile unsigned char* address;

class preciseTimer {
  public:
    preciseTimer();
    void addInterrupt(address interrupt, byte intBit);
    void queueNextEvent(unsigned long eventDelay, function scheduleFcn);
    void start();
    void clearQueue();
    void restoreInterrupts();
    void setInterruptBlockTime(unsigned long blockTime);
    void prepareForEvent();
    volatile unsigned int  timerOverflows;
    volatile function eventFcn;
    volatile unsigned long eventTime;
    volatile unsigned long preEventTime;
    
  private: 

    address interruptRegList[MAXINTREG];
    byte interruptBitList[MAXINTREG];
    volatile byte interruptStates[MAXINTREG];
    byte numInterrupts; 
    unsigned long interruptBlockTime;  
    
};

void nullFcn();

extern preciseTimer pT;

#endif
