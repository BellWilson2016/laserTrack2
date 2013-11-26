/* ScanDriver
 *
 * This Arduino sketch implements code for a fast scan mirror controller.  It receives serial data, passes it to a pair of Two-Wire DACs, 
 * orchestrates timing of the DACs and a laser command signal, and sends timing information back to the computer over USB.  It also 
 * manages a One-Wire thermometer.  It includes an improvedHardwareSerial.cpp class, and programatically increases the TWI clock speed
 * to 400 kHz.
 *
 * JSB 12/10/2012
 *
 * -------------------
 *
 * Outstanding Issues:
 *
 * Occasionally misses some timer intervals with dense serial returns.
 * Account for latency before mirror movement starts?
 *
 */

#include "improvedHardwareSerial.h"                    // Need to include is first before arduino.h is imported because this #ifndef's out the exsisting HardwareSerial core library.
#include "ScanDriverPinDefs.h"
#include <Wire.h>                                      // Nb. We programatically sets the TWI speed to 400 kHz at DAC setup.

// Video triggering
#define VIDTRIGINTERVAL 2
                                 
// In-line assembly utilities
#define NOP asm volatile("nop\n\t"::)
#define DONOTOPTIMIZE __attribute__((optimize("O0")))

// Time pads:
#define TRANSFERWINDOWSIZE (475ul <<  4)      // Allow 450 usec for serial and I2C transfers
#define TIMERCAPTUREPAD    ( 45ul <<  4)      // Don't loop again within this time of the trigger
#define TIMERWARNINGPAD    (  4ul <<  4)      // Throw timer warning if less time than this before trigger
#define LASERENDPAD        ( 95ul <<  4)      // Ensure laser off this long before mirror movement starts
#define LOSTCONTACTTIME    (  2ul << 25)      // Shut down the mirrors if you don't talk to the computer in about 4 sec. 2 << 25

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
  byte pulsePeriod = 0;    // Used for mode 4, pulsed stimulation
  byte LaserPhases[8] = {0,0,0,0,0,0,0,0};
  
  byte vidTrigPhase;
  byte dropFrames;
  
  
// Variables updated for each fly, 40 byte transmission
  byte Xpositions[16];
  byte Ypositions[16];
  byte LaserPowers[8] = {0,0,0,0,0,0,0,0};       // 0-255 scaled to 0 - scanTime microseconds
  byte LaserPowersBuffer[8] = {0,0,0,0,0,0,0,0}; // Buffer to sync with DAC
  
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
  

void setup() {
  
  setupPins();
  setupThermometer();
  setupDACs();

  // Setup timing, and start
  currentZone = ScanOrder[zoneIndex];
  nextDACIndex = zoneIndex + 1;
  nextTimeGap = (mirrorMoveTime[currentZone] << 4);   // Allow a large time gap to allow initialization
  SETCURRENTZONE;  // Outputs address of currentZone    
  
  setupSerial();
  
  setupUTimer();
  sreg = SREG;
  cli();
  prevTimePoint = uTimer();     // uTimer needs interrupts off
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



// Add space here to ensure interrupts can run?
// Or add space right before RETURN values?


  // Kill interrupts and get the time
  sreg = SREG;
  cli();
  timeNow = uTimer();
  
  // Check to see if we've missed a time target
  if ((long) (timeNow + TIMERWARNINGPAD - prevTimePoint) > nextTimeGap) {     
    // If we missed the interval, halt execution
    // catchError(MISSEDTIMERERROR);
    // If we missed the interval, notify via serial
    queueSerialReturn(0xfd, timeNow + TIMERWARNINGPAD - prevTimePoint - nextTimeGap); 
    // If we missed the interval, try to recover in 2 ms
    prevTimePoint += nextTimeGap;
    nextTimeGap = ((unsigned long) 1 << 14);
    SREG = sreg;
    return;
  }
  
  // If we're not at a time point, return and check again as soon as possible, 
  // otherwise proceed with fine timing.
  if ((long) (timeNow + TIMERCAPTUREPAD - prevTimePoint) < nextTimeGap) {
    SREG = sreg; 
    // If we're in a special mode, keep polling the serial port to make sure buffer doesn't overflow
    if (mode == 1) {
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
      SETCURRENTZONE;  // Outputs current zone address
      // Do a video trigger
      if (currentZone == 0) {
         if (dropFrames == 0) {
            VIDTRIGPINON;
            SREG = sreg;
            queueSerialReturn(0x64, prevTimePoint);
          } else {
            dropFrames--;
            SREG = sreg;
            queueSerialReturn(0x65, prevTimePoint);
          }         
        } else if (currentZone == 1) {
          VIDTRIGPINOFF;
          SREG = sreg;
        }      
 
//      if (currentZone == 0) {
//        vidTrigPhase++; vidTrigPhase %= VIDTRIGINTERVAL;
//        if (vidTrigPhase == 0) {
//            VIDTRIGPINON;
//        } else if (vidTrigPhase == 1) {
//            VIDTRIGPINOFF;
//        }      
//      } 
 
      SREG = sreg;
      
      // Mode 5 is frequency mode
      if (mode == 5) {
        // Pulse duratino comes from pulsePeriod global parameter
        laserDuration = (((unsigned long) pulsePeriod) * ((((unsigned long) scanTime) << 4) - LASERENDPAD)) >> 8;
        // If we're out of phase, don't laser and continue counting down
        if (LaserPhases[currentZone] > 0) {
          laserDuration = 0;
          LaserPhases[currentZone] -= 1;
        // If we are in phase and the power is > 0, allow laser and reset the countdown  
        } else if (LaserPowers[currentZone] > 0) {
          LaserPhases[currentZone] = 0xFF - LaserPowers[currentZone];
        // If the power is 0, don't reset the countdown and don't laser  
        } else {
         laserDuration = 0;
        } 
      } else {  
        laserDuration = (((unsigned long) LaserPowers[currentZone]) * ((((unsigned long) scanTime) << 4) - LASERENDPAD)) >> 8;
        // Implement pulsatile laser
        if (LaserPhases[currentZone] > 0) {
           laserDuration = 0;
           LaserPhases[currentZone] -= 1;
        } else if (laserDuration > 0) {
          LaserPhases[currentZone] = pulsePeriod;
        }
      }
        
      
      prevTimePoint += nextTimeGap;
      nextTimeGap = ((unsigned long) mirrorMoveTime[currentZone]) << 4;
      if (laserDuration == 0) {
        phase = 3;
      } else {
        phase = 1;
        // queueSerialReturn(0x10 + currentZone, prevTimePoint + nextTimeGap);                  // Denotes laser on.  Do this in advance in case of short laser epochs.
        // queueSerialReturn(0x18 + currentZone, prevTimePoint + nextTimeGap + laserDuration);  // Denotes laser off.
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
        nextTimeGap = (((unsigned long) scanTime) << 4) - ((unsigned long) laserDuration);  // The amount of time left in the laser phase
        phase = 0;
        // If there's enough time to Rx or Tx check the serial port and I2C
        checkForTransfers(); 
        // Update zone here for speed at start of phase 0
        zoneIndex++;  zoneIndex %= numZones;       
        currentZone = ScanOrder[zoneIndex]; 
        // queueSerialReturn(0x00 + currentZone, prevTimePoint + nextTimeGap);  // Denotes mirror movement.
      break;
        
    // Phase 3 is an epoch without any lasing
    case 3:
        // Don't turn on the laser
        SREG = sreg;
        LASERPINOFF;
        phase = 0;
        if (mode == 1) {
          mode = 0;   // Needed to recover from watchdog test mode
        }
        prevTimePoint += nextTimeGap;
        nextTimeGap = ((unsigned long) scanTime) << 4;        
        // If there's enough time to Rx or Tx check the serial port and I2C
        checkForTransfers();      
        // Update zone here for speed at start of phase 0
        zoneIndex++;  zoneIndex %= numZones;
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

  



