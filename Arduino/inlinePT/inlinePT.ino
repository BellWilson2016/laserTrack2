#define DACPINON     PORTD |= B00010000
#define DACPINOFF    PORTD &= B11101111
#define SERIALPINON  PORTD |= B00001000
#define SERIALPINOFF PORTD &= B11110111
#define LASERPINON   PORTD |= B00100000
#define LASERPINOFF  PORTD &= B11011111
#define SERIALSYNCPIN 3
#define DACSYNCPIN 4
#define LASERPIN 5

unsigned long timerOverflows;
typedef void (*function)();

function eventFcn;

void setup() {
  
  pinMode(SERIALSYNCPIN, OUTPUT); digitalWrite(SERIALSYNCPIN, LOW);
  pinMode(DACSYNCPIN, OUTPUT);    digitalWrite(DACSYNCPIN, LOW);
  pinMode(LASERPIN, OUTPUT);      digitalWrite(LASERPIN, LOW);
  
  setupPreciseTimer();
  start();
}

int i;

void loop() {
  i++;
}

void setupPreciseTimer() {
     
  // Add the timer overflow interrupt to the list of interrupts to defer
  // addInterrupt(&TIMSK1, (1 << TOIE1));
  
  // Configure timer in normal mode (pure counting, no PWM etc.)
  TCCR1A &= 0;  
  TCCR1B &= 0;
  TCCR1C &= 0;
  TIMSK1 &= 0;
  
  // Turn off compare match A,B, turn on overflow interrupt enable
  TIMSK1 |= ((0<<OCIE1A) | (0<<OCIE1B) | (1<<TOIE1));   
}

ISR(TIMER1_OVF_vect) {
  timerOverflows++;  
  if (timerOverflows % 2) {
    DACPINON;   
  } else {
    DACPINOFF;    
  }
}


void start() {
  
  byte sreg;
  
  // Disable interrupts, write timer to zero
  sreg = SREG;
  cli();
  TCNT1 = 0;
  // eventTime = 0;
  timerOverflows = 0;
  // Turn on timer clock
  TCCR1B |=   (0<<CS12)|(0<<CS11)|(1<<CS10); 
  SREG = sreg; 
}
