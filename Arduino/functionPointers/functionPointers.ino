#define DACPINON     PORTD |= B00010000
#define DACPINOFF    PORTD &= B11101111
#define SERIALPINON  PORTD |= B00001000
#define SERIALPINOFF PORTD &= B11110111
#define LASERPINON   PORTD |= B00100000
#define LASERPINOFF  PORTD &= B11011111
#define NOP asm volatile("nop\n\t"::)
#define SERIALSYNCPIN 3
#define DACSYNCPIN 4
#define LASERPIN 5

typedef void (*function)();

function nextFcn;

void setup() {
  
  pinMode(SERIALSYNCPIN, OUTPUT); digitalWrite(SERIALSYNCPIN, LOW);
  pinMode(DACSYNCPIN, OUTPUT);    digitalWrite(DACSYNCPIN, LOW);
  pinMode(LASERPIN, OUTPUT);      digitalWrite(LASERPIN, LOW);
  
  nextFcn = turnOn;
  
}

void loop() {
  nextFcn();
}

void turnOn() {
  DACPINON;
  nextFcn = turnOff;
}
void turnOff() {
  DACPINOFF;
  nextFcn = turnOn;
}

