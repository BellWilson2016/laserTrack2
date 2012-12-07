#include <Wire.h>
#include "ScanDriverPinDefs.h"
#define BAUDRATE 115200        // Serial baudrate
#define POSPOWERSIZE 41        // Size of data transmissions blocks
#define SCANPARAMSIZE 27
#define MODEPARAMSIZE 3        // Size of special mode parameters
#define WRITECODE B00110000    // Writes and updates to DAC
#define XDACADDR B1010100      // XDAC I2C Address
#define YDACADDR B1010111      // YDAC I2C Address
#define ADDRMASK 7
#define SERIALPINON  PORTD |= B00001000
#define SERIALPINOFF PORTD &= B11110111
#define LASERPINON   PORTD |= B00100000
#define LASERPINOFF  PORTD &= B11011111
#define DACPINON     PORTD |= B00010000
#define DACPINOFF    PORTD &= B11101111
#define SYNC1PINON   PORTD |= B01000000
#define SYNC1PINOFF  PORTD &= B10111111
#define NOP asm volatile("nop\n\t"::)
#define TRANSFERWINDOWSIZE (450ul << 4)      // Allow 450 usec for serial and I2C transfers
#define STORAGESIZE 256                     // Storage buffer for serial return
#define LOSTCONTACTTIME   ((unsigned long) 2 << 25)  // Shut down the mirrors if you don't talk to the computer in about 4 sec.
#define DONOTOPTIMIZE __attribute__((optimize("O0")))

// Time pads:
#define TIMERCAPTUREPAD  (40ul << 4)      // Don't loop again within...
#define TIMERWARNINGPAD  (10ul << 4)      // Throw timer warning if less time
#define LASERENDPAD      (95ul << 4)      // Laser epoch end to mirror movement


// Error codes:
#define MISSEDTIMERERROR 5
#define WRONGSWITCHCASE  6
#define STORAGEFULL      7
 
// Issues:
// 
// Remember to set I2C speed to 400kHz in the environment
// Remember to set Serial buffer to 128 bytes in the environment
// Edited HardwareSerial.cpp to flag buffer overruns, 
//         allow manual read of hardware buffer, and test for tx buffer space
//         Need to bring this in as a daughter class
// Serial interrupt problems with dense serial returns
// Account for latency before mirror movement starts


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
  volatile unsigned long uTimerOverflows;
  volatile boolean rollFlag;
  unsigned long timeNow;            // Current time
  unsigned long nextTimeGap;
  unsigned long prevTimePoint;
  unsigned long lastComputerContact;
  unsigned char sreg;                            // System registers for timer disabling
  
  // Variables for thermometer
  unsigned long thermDelay;
  unsigned long lastTemp;
  boolean tempLock;
  
  // Variables for Serial Return
  unsigned long returnTimes[STORAGESIZE];
  byte          returnData[STORAGESIZE];
  byte retDataIdxH;
  byte retDataIdxGap;
  
 
  
 
void setup() {
  
  
  // Setup pins
 pinMode(SERIALSYNCPIN, OUTPUT); digitalWrite(SERIALSYNCPIN, LOW);
 pinMode(DACSYNCPIN, OUTPUT);    digitalWrite(DACSYNCPIN, LOW);
 pinMode(LASERPIN, OUTPUT);      digitalWrite(LASERPIN, LOW);
 pinMode(SYNC1PIN, OUTPUT);      digitalWrite(SYNC1PIN, LOW);
 pinMode(SYNC2PIN, OUTPUT);      digitalWrite(SYNC2PIN, LOW);
 pinMode(A0PIN, OUTPUT); 
 pinMode(A1PIN, OUTPUT);
 pinMode(A2PIN, OUTPUT);
 pinMode(CLRPIN, OUTPUT);
 pinMode(XLDACPIN, OUTPUT);
 pinMode(YLDACPIN, OUTPUT);
 
  // Initialize thermometer
  setupThermometer();
 
  // Initialize the DACs
  setupDACs();

  // Setup timing, and start
  currentZone = ScanOrder[zoneIndex];
  nextDACIndex = zoneIndex + 1;
  nextTimeGap = (mirrorMoveTime[currentZone] << 4);   // Allow a large time gap to allow initialization
  PORTB = (currentZone & ADDRMASK) | (PORTB & ~ADDRMASK);  // Outputs address of currentZone    
  
  // Setup Serial Link
  Serial.begin(BAUDRATE);
  
  setupUTimer();
  sreg = SREG;
  cli();
  prevTimePoint = uTimer(); // uTimer needs interrupts off
  SREG = sreg;
  lastComputerContact = prevTimePoint;
    
}





void loop() {
  
    
  int i,j;
  unsigned int coarseDelayTime;
  byte           fineDelayTime;  
  
// Throttling code to stress-test for inexpected interrupt combinations
//    that cause missed timer events.
//  i = 0;
//  while (i < 20) {
//        NOP; NOP; NOP; NOP;
//        i++;     
//  }


  // Kill interrupts and get the time
  sreg = SREG;
  cli();
  timeNow = uTimer();
  
  // Check to see if we've missed a time target
  if ((timeNow + TIMERWARNINGPAD - prevTimePoint) > nextTimeGap) {
    // If we missed the interval throw an error!
    catchError(MISSEDTIMERERROR);
    queueSerialReturn(0xfd, timeNow - prevTimePoint - nextTimeGap); 
    // If we missed the interval, try to recover in 2 ms
    nextTimeGap = ((unsigned long) 1 << 15);
    SREG = sreg;
    return;
  }
  
  // If we're not at a time point, return and check again as soon as possible, 
  // otherwise proceed with fine timing.
  if ((timeNow + TIMERCAPTUREPAD - prevTimePoint) < nextTimeGap) {
    SREG = sreg; 
    // If we're in a special mode, keep polling the serial port to make sure buffer doesn't overflow
    if (mode > 0) {
      availableBytes = Serial.available();
      if ((availableBytes > 0) && (availableBytes >= Serial.peek())) {
            receiveSerial();
      }
    }
    return;
  }
   
  

  // Calculate the gap until the next target time.  Then delay for the gap.
  coarseDelayTime = (nextTimeGap - (timeNow - prevTimePoint));
  fineDelayTime   = (byte) coarseDelayTime & B00000111; 
  coarseDelayTime = coarseDelayTime >> 3;
     
  // Execute the delay 
  // .5 us per loop
  i = 0;
  while (i < coarseDelayTime) {
    i++;
    NOP;
    NOP;
  }
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
                "nop                   \n\t" 
                "nop                   \n\t" 
                "nop                   \n\t" 
                "nop                   \n\t" 
              "end:                    \n\t"
            :
            : [delay] "r" (fineDelayTime)
            :
            "r30","r31");

         
  // Do the code, remember to turn interrupts back on!        
  switch (phase) {
    
    // Phase 0 is End of lasing until mirror movement  
    case 0: 
      // Find the next zone and output it
      PORTB = (currentZone & ADDRMASK) | (PORTB & ~ADDRMASK);  // Outputs address of currentZone
      SREG = sreg;
      laserDuration = (((unsigned long) LaserPowers[currentZone]) * ((((unsigned long) scanTime) << 4) - LASERENDPAD))/255;  
      prevTimePoint += nextTimeGap;
      nextTimeGap = ((unsigned long) mirrorMoveTime[currentZone]) << 4;
      if (laserDuration == 0) {
        phase = 3;
      } else {
        phase = 1;
        queueSerialReturn(0x10 + currentZone, prevTimePoint + nextTimeGap);                  // Denotes laser on.  Do this in advance in case of short laser epochs.
        queueSerialReturn(0x18 + currentZone, prevTimePoint + nextTimeGap + laserDuration);  // Denotes laser off.
      }     
      break;
    
    // Phase 1 is start of mirror movement until Laser ON
    case 1:       
        // Short delay for alignment
        NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
        // Turn on the laser
        LASERPINON;
        // For long pulses, go back through the counter
        if (laserDuration > (85 << 4)) {         
            SREG = sreg;
            phase = 2;
            prevTimePoint += nextTimeGap;
            nextTimeGap = ((unsigned long) laserDuration);
            checkForTransfers();        
        // But for short pulses, delay a bit, then jump right to the next phase     
        } else {
              
              // Calculate a non-negative delay
              if (laserDuration > 80) {
                coarseDelayTime = laserDuration - 80;    // Magic number to sync short laser times with long times
              } else { 
                coarseDelayTime = 0;
              }
              fineDelayTime   = (byte) coarseDelayTime & B00000111; 
              coarseDelayTime = coarseDelayTime >> 3;
//            // Execute the delay 
//            // .5 us per loop
              i = 0;
              while (i < coarseDelayTime) {
                i++;
                NOP;
                NOP;
              }
              // Cycle-accurate assembly delay
              asm volatile( "ldi r30, pm_lo8(endL)  \n\t"   
                            "ldi r31, pm_hi8(endL)  \n\t" 
                            "sub r30, %[delay]     \n\t"
                            "sbc r31, __zero_reg__ \n\t"
                            "ijmp                  \n\t"
                          "beginL:                  \n\t" 
                            "nop                   \n\t" 
                            "nop                   \n\t" 
                            "nop                   \n\t" 
                            "nop                   \n\t" 
                            "nop                   \n\t" 
                            "nop                   \n\t" 
                            "nop                   \n\t" 
                            "nop                   \n\t" 
                          "endL:                    \n\t"
                        :
                        : [delay] "r" (fineDelayTime)
                        :
                        "r30","r31");
            prevTimePoint += nextTimeGap;
            nextTimeGap = ((unsigned long) laserDuration);
            goto LaserOff; // Interrupts will be turned on at LaserOff:
        }
        break;
        
    // Phase 2 is Laser ON until Laser OFF    
    case 2:
        // Short delay for alignment
        NOP; NOP; NOP; NOP;          
        // Turn off the laser
     LaserOff:   
        LASERPINOFF;
        SREG = sreg;
        prevTimePoint += nextTimeGap;
        nextTimeGap = (((unsigned long) scanTime) << 4) - nextTimeGap;  // The amount of time left in the laser phase
        phase = 0;
        // If there's enough time to Rx or Tx check the serial port and I2C
        checkForTransfers(); 
        // Update zone here for speed at start of phase 0
        zoneIndex++;
        if (zoneIndex >= numZones) {zoneIndex = 0;}
        currentZone = ScanOrder[zoneIndex]; 
        // queueSerialReturn(0x00 + currentZone, prevTimePoint + nextTimeGap);  // Denotes mirror movement.
      break;
        
    // Phase 3 is an epoch without any lasing
    case 3:
        // Don't turn on the laser
        SREG = sreg;
        LASERPINOFF;
        phase = 0;
        mode = 0;   // Needed to recover from watchdog test mode
        prevTimePoint += nextTimeGap;
        nextTimeGap = ((unsigned long) scanTime) << 4;        
        // If there's enough time to Rx or Tx check the serial port and I2C
        checkForTransfers();
        
        // Update zone here for speed at start of phase 0
        zoneIndex++;
        if (zoneIndex >= numZones) {zoneIndex = 0;}
        currentZone = ScanOrder[zoneIndex]; 
        // queueSerialReturn(0x00 + currentZone, prevTimePoint + nextTimeGap);  // Denotes mirror movement.
        break;
    
    // We shouldn't ever get here...    
    default:
        catchError(WRONGSWITCHCASE);
        SREG = sreg;
        break;   
  }
  
    
}

  


