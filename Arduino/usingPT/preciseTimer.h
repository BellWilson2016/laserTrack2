#ifndef PRECISETIMER_H
#define PRECISETIMER_H


#include <inttypes.h>

typedef void (*function)();
typedef unsigned char byte;

class preciseTimer {
  public:
    preciseTimer();
    void addInterrupt(volatile unsigned char * interrupt, byte intBit);
    void queueNextEvent(unsigned long eventDelay, function scheduleFcn);
    void clearQueue();
    void restoreInterrupts();
    void setInterruptBlockTime(unsigned long blockTime);
  private:
    void prepareForEvent();
    void blockInterrupts();
    volatile unsigned char * interruptRegList[];
    byte interruptBitList[];
    byte interruptStates[];
    byte numInterrupts;
    unsigned int  timerOverflows;
    unsigned long eventTime;
    function eventFcn;
    unsigned long interruptBlockTime;
    
};

extern preciseTimer pT;

#endif
