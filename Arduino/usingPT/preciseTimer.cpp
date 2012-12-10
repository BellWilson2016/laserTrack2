#include "preciseTimer.h"

#include <avr/io.h>
#include <avr/interrupt.h>

#define MAXINTREG 20

volatile unsigned char * interruptRegList[MAXINTREG];
byte interruptBitList[MAXINTREG];
byte interruptStates[MAXINTREG];
byte numInterrupts = 0;
unsigned long eventTime;
function eventFcn;
unsigned long interruptBlockTime = 0;
unsigned int  timerOverflows = 0;

// Set it up
preciseTimer::preciseTimer(){
  
  // Add the timer overflow interrupt to the list of interrupts to defer
  addInterrupt(&TIMSK1, TOIE1);
  
  byte sreg;
  
   // Disable timer during setup 
  TIMSK1 &= ~(1<<TOIE1);  
  
  // Configure timer in normal mode (pure counting, no PWM etc.)
  TCCR1A &= ~((1<<WGM11) | (1<<WGM10));  
  TCCR1A &= ~((1<<COM1A1)|(1<<COM1A0)|(1<<COM1B1)|(1<<COM1B0)); 
  // Set prescaler to CPU clock divided by 1 
  TCCR1B &=   ~(7);
  TCCR1B |=   (0<<CS12)|(0<<CS11)|(1<<CS10); 
  // Turn off FOC
  TCCR1C = 0;
  
  // Turn off compare match A,B and turn on overflow interrupt enable
  TIMSK1 |= ((0<<OCIE1A) | (0<<OCIE1B) | (1<<TOIE1));  
 
  // Disable interrupts, write timer to zero
  sreg = SREG;
  cli();
  TCNT1 = 0;
  SREG = sreg;
}

void preciseTimer::addInterrupt(volatile unsigned char * interrupt, byte intBit) {
  interruptRegList[numInterrupts] = interrupt;
  interruptBitList[numInterrupts] = (1 << intBit);
  numInterrupts++;
}


void preciseTimer::setInterruptBlockTime(unsigned long blockTime) {
  interruptBlockTime = blockTime;
}

void preciseTimer::queueNextEvent(unsigned long eventDelay, function scheduleFcn) {
  
  unsigned long preEventTime;
  byte sreg;
  
  eventFcn = scheduleFcn;
  
  eventTime += eventDelay;
  preEventTime = eventTime - interruptBlockTime;
  
  // Set the timer interrupts to the correct times
  sreg = SREG;
  cli();
  OCR1A = preEventTime & 0xFFFF;
  OCR1B = eventTime & 0xFFFF;
  SREG = sreg;
  
  // Turn on interrupt A
  TIMSK1 |= (1 << OCIE1A);
}

void preciseTimer::clearQueue() {
  TIMSK1 &= ~((1 << OCIE1A) | (1 << OCIE1B));
}

void preciseTimer::prepareForEvent() {
  
  // If we're not in the correct timer era then return
  if (timerOverflows != ((eventTime - interruptBlockTime) >> 16)) {
    return;
  }
  
  blockInterrupts();
  
  // Turn off interrupt A
  TIMSK1 &= ~(1 << OCIE1A);
  // Turn on interrupt B
  TIMSK1 |= (1 << OCIE1B);
}

void preciseTimer::blockInterrupts() {
  
   int i;
   
   // Store the state of each interrupt and turn them off
   for (i=0; i < numInterrupts; i++) {
     interruptStates[i] = ((byte) *(interruptRegList[i])) & interruptBitList[i];
     *(interruptRegList[i]) &= ~(interruptBitList[i]);
   }
}
    
    
void preciseTimer::restoreInterrupts() {
   
  int i;
   
   for (i=0; i < numInterrupts; i++) {
     *(interruptRegList[i]) |= interruptStates[i];
   }
}


ISR(TIMER1_OVF_vect) {
  timerOverflows++;
}
ISR(TIMER1_COMPA_vect) {
  prepareForEvent();
}
ISR(TIMER1_COMPB_vect) {
  // Turn off interrupt B
  TIMSK1 &= ~(1 << OCIE1B);
  eventFcn();
}

preciseTimer pT;


