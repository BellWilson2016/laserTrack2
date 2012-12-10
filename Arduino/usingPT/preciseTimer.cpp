#include "preciseTimer.h"


#include <avr/io.h>
#include <avr/interrupt.h>

#define MAXINTREG   20
#define PREEVENTPAD 200
#define ERRSCHEDTOOSOON    0
#define ERRISRSTILLRUNNING 1

volatile unsigned char * interruptRegList[MAXINTREG];
byte interruptBitList[MAXINTREG];
byte interruptStates[MAXINTREG];
byte numInterrupts = 0;
unsigned long eventTime;
function eventFcn;
errorFunction errorFcn;
unsigned long interruptBlockTime = 0;
unsigned int  timerOverflows = 0;
boolean isrRunning = false;

// Set it up
preciseTimer::preciseTimer(){
   
  eventFcn = (function) &preciseTimer::nullFcn;
  errorFcn = (errorFunction) &preciseTimer::nullErrorFcn;
  
  // Add the timer overflow interrupt to the list of interrupts to defer
  addInterrupt(&TIMSK1, (1 << TOIE1));
  
  // Configure timer in normal mode (pure counting, no PWM etc.)
  TCCR1A &= ~((1<<WGM11) | (1<<WGM10));  
  TCCR1A &= ~((1<<COM1A1)|(1<<COM1A0)|(1<<COM1B1)|(1<<COM1B0)); 
  // Set prescaler to CPU clock off 
  TCCR1B &=   ~(7);
  TCCR1B |=   (0<<CS12)|(0<<CS11)|(0<<CS10); 
  // Turn off FOC
  TCCR1C = 0;
  
  // Turn off compare match A,B, turn on overflow interrupt enable
  TIMSK1 |= ((0<<OCIE1A) | (0<<OCIE1B) | (1<<TOIE1));   
}

void preciseTimer::addInterrupt(volatile unsigned char * interrupt, byte intBit) {
  interruptRegList[numInterrupts] = interrupt;
  interruptBitList[numInterrupts] = intBit;
  numInterrupts++;
}


void preciseTimer::setInterruptBlockTime(unsigned long blockTime) {
  interruptBlockTime = blockTime;
}

void preciseTimer::queueNextEvent(unsigned long eventDelay, function scheduleFcn) {
  
  unsigned long preEventTime;
  byte sreg;
  unsigned int currentCounts;
  unsigned long currentTime;
  unsigned long overflows;
  
  eventFcn = scheduleFcn;
  eventTime += eventDelay;
  preEventTime = eventTime - interruptBlockTime;
  
  // Check to see if the event has already passed
  sreg = SREG;
  cli();
  currentCounts = TCNT1;
  overflows = timerOverflows;
  currentTime = ((overflows << 16) + ((unsigned long) currentCounts));
  if ((TIFR1 & (1<<TOV1)) && (currentCounts < 0xFFF5)) {
        currentTime += (1 << 16) + 13;
  }    
//  // If there's not enough time to catch the interrupt, throw an error and run the function
//  if ((long) (preEventTime - currentTime) > PREEVENTPAD) {
//    errorFcn(ERRSCHEDTOOSOON);
//    eventFcn();
//  }
  
  // Set the timer interrupts to the correct times
  OCR1A = preEventTime & 0xFFFF;
  OCR1B = eventTime & 0xFFFF;
  
  // Turn on interrupt A
  TIMSK1 |= (1 << OCIE1A);
  SREG = sreg;
}

void preciseTimer::clearQueue() {
  TIMSK1 &= ~((1 << OCIE1A) | (1 << OCIE1B));
}

void preciseTimer::start() {
  
  byte sreg;
  
  // Disable interrupts, write timer to zero
  sreg = SREG;
  cli();
  TCNT1 = 0;
  eventTime = 0;
  timerOverflows = 0;
  // Turn on timer clock
  TCCR1B |=   (0<<CS12)|(0<<CS11)|(1<<CS10); 
  SREG = sreg; 
}

void preciseTimer::prepareForEvent() {
  
  int i;
  //DACPINON;
  // If we're not in the correct timer era then return
//  if (timerOverflows != ((eventTime - interruptBlockTime) >> 16)) {
//    return;
//  }
  
  // If an ISR is still running when we're preparing, throw an error
  if (isrRunning) {
    //errorFcn(ERRISRSTILLRUNNING);
  }
  
//   // Store the state of each interrupt and turn them off
//   for (i=0; i < numInterrupts; i++) {
//     interruptStates[i] = ((byte) *(interruptRegList[i])) & interruptBitList[i];
//     *(interruptRegList[i]) &= ~(interruptBitList[i]);
//   }
  
  // Turn off interrupt A
  TIMSK1 &= ~(1 << OCIE1A);
  // Turn on interrupt B
  TIMSK1 |= (1 << OCIE1B);
}


void preciseTimer::nullFcn() {
}
void preciseTimer::nullErrorFcn(int anError) {
}
    
    
void preciseTimer::restoreInterrupts() {
   
  int i;
   
//   for (i=0; i < numInterrupts; i++) {
//     *(interruptRegList[i]) |= interruptStates[i];
//   }
//   sei(); // Restore the global interrupt enable bit
}


void preciseTimer::setErrorFcn(errorFunction anErrorFcn) {
  errorFcn = anErrorFcn;
}

ISR(TIMER1_OVF_vect) {
  timerOverflows++;  
  if (timerOverflows % 2) {
    DACPINON;   
  } else {
    DACPINOFF;    
  }
}
ISR(TIMER1_COMPA_vect) {
  SERIALPINON;
  pT.prepareForEvent();
  SERIALPINOFF;
}

ISR(TIMER1_COMPB_vect) {
  LASERPINON;
  // Turn off interrupt B
  TIMSK1 &= ~(1 << OCIE1B);
  pT.isrRunning = true;
  eventFcn();
  //DACPINOFF;
  pT.isrRunning = false;
  LASERPINOFF;
}

preciseTimer pT;


