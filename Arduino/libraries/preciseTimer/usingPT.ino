#include "preciseTimer.h"

void setup() {
  
  pinMode(SERIALSYNCPIN, OUTPUT); digitalWrite(SERIALSYNCPIN, LOW);
  pinMode(DACSYNCPIN, OUTPUT);    digitalWrite(DACSYNCPIN, LOW);
  pinMode(LASERPIN, OUTPUT);      digitalWrite(LASERPIN, LOW);
  
  Serial.begin(115200);
  
  // Set interrupts to be cleared
  
  pT.addInterrupt(&TIMSK0,(1<<OCIE0B)|(1<<OCIE0A)|(1<<TOIE0));
  pT.addInterrupt(&TIMSK2,(1<<OCIE2B)|(1<<OCIE2A)|(1<<TOIE2));
  pT.addInterrupt(&UCSR0B,(1<<RXCIE0)|(1<<TXCIE0)|(1<<UDRIE0));
  pT.addInterrupt(&TWCR,  (1<<TWIE));
 
  pT.setInterruptBlockTime(30ul << 4);
  pT.start();
  pT.queueNextEvent((500ul << 4), turnOn);


}

int i;

void loop() {
  i++;
}

void turnOn() {
  LASERPINON;
  pT.restoreInterrupts();
  pT.queueNextEvent((80ul << 4), turnOff);
}
void turnOff() {
  LASERPINOFF;
  pT.restoreInterrupts();
  pT.queueNextEvent((500ul << 4), turnOn);  
}


