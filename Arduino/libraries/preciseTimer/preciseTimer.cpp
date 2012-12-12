#include "preciseTimer.h"

#include <avr/io.h>
#include <avr/interrupt.h>

#define ERRSCHEDTOOSOON    0
#define ERRISRSTILLRUNNING 1

address interruptRegList[MAXINTREG];
byte interruptBitList[MAXINTREG];
volatile byte interruptStates[MAXINTREG];
byte numInterrupts = 0;
volatile unsigned long eventTime;
volatile unsigned long preEventTime;
volatile function eventFcn;
unsigned long interruptBlockTime = 0;
volatile unsigned int  timerOverflows = 0;


// Default constructor - note that something else writes to timer registers after object construction
preciseTimer::preciseTimer() {
      
  eventFcn = nullFcn;
  
  // Add the timer overflow interrupt to the list of interrupts to defer
  addInterrupt(&TIMSK1, (1 << TOIE1));
  eventTime = 0;
}

void preciseTimer::addInterrupt(address interrupt, byte intBit) {
  interruptRegList[numInterrupts] = interrupt;
  interruptBitList[numInterrupts] = intBit;
  numInterrupts++;
}


void preciseTimer::setInterruptBlockTime(unsigned long blockTime) {
  interruptBlockTime = blockTime;
}

void preciseTimer::queueNextEvent(unsigned long eventDelay, function scheduleFcn) {
  
  byte sreg;
  unsigned long currentCounts;
  unsigned long currentTime;
  
  eventFcn = scheduleFcn;
  eventTime += eventDelay;
  preEventTime = eventTime - interruptBlockTime;
  
  // Check to see if the event has already passed
  sreg = SREG;
  cli();
  currentCounts = (unsigned long) TIFR1;
  // If there's an unaccounted for rollover, account for it 
  if ((TIFR1 & (1<<TOV1)) && (currentCounts < 0xFFF5)) {
    TIFR1 = (1<<TOV1); // Clear TOV1 so we don't double count
    timerOverflows++;
  }
  currentTime = ((unsigned long) timerOverflows) << 16 + currentCounts;
  // If there's not enough time to catch the interrupt, throw an error and run the function
  if ((long) (preEventTime - currentTime) < PREEVENTPAD) {
    eventFcn();
  }
  
  // Clear interrupt flags, set timers to correct times
  TIFR1 = (1<<OCF1A) | (1<<OCF1B);
  OCR1A = preEventTime & 0xFFFF;
  OCR1B = eventTime & 0xFFFF;
  
  // Turn on interrupt A
  TIMSK1 |= (1 << OCIE1A);
  SREG = sreg;
}

void preciseTimer::clearQueue() {  
  TIMSK1 &= ~((1 << OCIE1A) | (1 << OCIE1B));
  TIFR1 = (1<<OCF1A) | (1<<OCF1B);
}

void preciseTimer::start() {
  
  byte sreg;

  // Disable interrupts
  sreg = SREG;
  cli();

  // Configure timer in normal mode (pure counting, no PWM etc.), but off
  TCCR1A &= 0;  
  TCCR1B &= 0;
  TCCR1C &= 0;
  TIMSK1 &= 0;  
 
  // Set clock to zero
  TCNT1 = 0;
  timerOverflows = 0;

  // Clear timer interrupt flags
  TIFR1 = (1<<TOV1) | (1<<OCF1A) | (1<<OCF1B);
  // Turn on timer clock, set to trigger at 1
  TCCR1B |= ((0<<CS12) | (0<<CS11) | (1<<CS10)); 
  TIMSK1 |= ((1<<OCIE1A) | (0<<OCIE1B) | (1<<TOIE1));

  // Turn interrupts back on
  SREG = sreg; 
  
}

void preciseTimer::prepareForEvent() {
  
  int i;
  
  // If we're not in the correct timer era then return
  if (timerOverflows != ((unsigned int) (preEventTime >> 16))) {
  //  return;
  } 
    
  // Store the state of each interrupt and turn them off
  for (i=0; i < numInterrupts; i++) {
     interruptStates[i] = ((byte) *(interruptRegList[i])) & (interruptBitList[i]);
     *(interruptRegList[i]) &= ~(interruptStates[i]);
  }
  
    
      // Turn off interrupt A
      TIMSK1 &= ~(1 << OCIE1A);
      // Clear interrupt B flag
      TIFR1 = (1<<OCF1B);
      // Turn on interrupt B
      TIMSK1 |= (1 << OCIE1B);
}
   
    
void preciseTimer::restoreInterrupts() {
   
   int i;
   
     for (i=0; i < numInterrupts; i++) {
          *(interruptRegList[i]) |= (interruptStates[i]);
     }
     sei(); // Restore the global interrupt enable bit
}


ISR(TIMER1_OVF_vect) {
  
  pT.timerOverflows++;
  //PORTD ^= B00010000;
}
ISR(TIMER1_COMPA_vect) {
  // If there's an unaccounted for rollover, account for it if we're
  // triggering near the start of an era
  unsigned int targetTime;
  targetTime = pT.eventTime & 0xffff;
  if ((TIFR1 & (1<<TOV1)) && (targetTime < (10u << 4))) {
	//PORTD ^= B00010000;
    TIFR1 = (1<<TOV1); // Clear TOV1 so we don't double count
    pT.timerOverflows++;
  }
  pT.prepareForEvent();
}
//
ISR(TIMER1_COMPB_vect) {
  
    byte fineIntDelayTime;
    int timeIntNow;
    timeIntNow = TCNT1;    
    fineIntDelayTime = 4 - ((timeIntNow - (pT.eventTime & 0xffff) + 3) % 4);
    
    // ISR has variable return times, so remove this
    // Cycle-accurate assembly delay
    asm volatile( "ldi r30, pm_lo8(end)  \n\t"   
                  "ldi r31, pm_hi8(end)  \n\t" 
                  "sub r30, %[delay]     \n\t"
                  "sbc r31, __zero_reg__ \n\t"
                  "ijmp                  \n\t"
                "begin:                  \n\t" 
                  "nop                   \n\t" 
                  "nop                   \n\t" 
                  "nop                   \n\t" 
                  "nop                   \n\t" 
                "end:                    \n\t"
              :
              : [delay] "r" (fineIntDelayTime)
              :
              "r30","r31");
       
    // Turn off interrupt B
    TIMSK1 &= ~(1 << OCIE1B);
    pT.eventFcn();
}


void nullFcn() {
}

preciseTimer pT;




