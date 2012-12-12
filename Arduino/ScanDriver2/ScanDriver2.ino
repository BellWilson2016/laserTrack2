#include "ScanDriverPinDefs.h"
#include "improvedHardwareSerial.h"                    // Need to include is first before arduino.h is imported because this #ifndef's out the exsisting HardwareSerial core library.
#include <Wire.h>                                      // Nb. We programatically sets the TWI speed to 400 kHz at DAC setup.
#include <preciseTimer.h>

// In-line assembly utilities
#define NOP asm volatile("nop\n\t"::)
#define DONOTOPTIMIZE __attribute__((optimize("O0")))

// Time pads:
#define LASERENDPAD        ( 95ul <<  4)      // Ensure laser off this long before mirror movement starts
#define LOSTCONTACTTIME    (  2ul << 25)      // Shut down the mirrors if you don't talk to the computer in about 4 sec.

// Error codes:
#define MISSEDTIMERERROR 5
#define WRONGSWITCHCASE  6
#define STORAGEFULL      7

  // Variable definitions
  byte availableBytes;
  byte transmissionSize;
  byte DACsLeftToUpdate;
  
  byte mode;      
  byte phase;
  byte currentZone;
  
  // Variables updated for each fly, 40 byte transmission
  byte Xpositions[16];
  byte Ypositions[16];
  byte LaserPowers[8] = {0,0,0,0,0,0,0,0};  // 0-255 scaled to 0 - scanTime microseconds
  
  // Scan movement parameters, 28 byte transmission
  unsigned int  scanTime =  971u;            // Max microseconds to allow for each laser hit.
  unsigned long  halfTime =  ((unsigned long) scanTime) << 3;
  unsigned long laserDuration;
  unsigned int mirrorMoveTime[8] = {566u,238u,238u,238u,238u,238u,238u,238u};   // Microseconds to allow for each mirror movement to this position.
  byte ScanOrder[8] = {0,1,2,3,4,5,6,7};                // Contains next target for each currentZone
  byte numZones = 8;
  byte zoneIndex;
  byte nextDACIndex;
 
  // Code for precise timer
  unsigned long nextTimeGap;
  unsigned long lastComputerContact;
  unsigned char sreg;                            // System registers for timer disabling
  
  // Variables for thermometer
  unsigned long thermDelay;
  unsigned long lastTemp;
  boolean tempLock;
  
void setup() {
  
  setupPins();
  setupThermometer();
  setupDACs();

  // Setup timing, and start
  currentZone = ScanOrder[zoneIndex];
  nextDACIndex = zoneIndex + 1;
  SETCURRENTZONE;  // Outputs address of currentZone    
  
  setupSerial();

  pT.addInterrupt(&TIMSK0,(1<<OCIE0B)|(1<<OCIE0A)|(1<<TOIE0));
  pT.addInterrupt(&TIMSK2,(1<<OCIE2B)|(1<<OCIE2A)|(1<<TOIE2));
  pT.addInterrupt(&UCSR0B,(1<<RXCIE0)|(1<<TXCIE0)|(1<<UDRIE0));
  pT.addInterrupt(&TWCR,  (1<<TWIE));
 
  pT.setInterruptBlockTime(45ul << 4);
  pT.start();
  pT.queueNextEvent((mirrorMoveTime[currentZone] << 4), phase3);
  
  lastComputerContact = pT.eventTime; 
}

void loop() {
    
}

  
  
  
  
