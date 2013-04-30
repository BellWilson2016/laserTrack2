// Serial port parameters
#define BAUDRATE 115200        // Serial baudrate
#define POSPOWERSIZE 41        // Size of data transmissions blocks
#define SCANPARAMSIZE 27
#define MODEPARAMSIZE 3        // Size of special mode parameters

// Variables for Serial Return Storage buffer
#define STORAGESIZE 256   
unsigned long returnTimes[STORAGESIZE];
byte          returnData[STORAGESIZE];
byte retDataIdxH;
byte retDataIdxGap;


void setupSerial() {
  Serial.begin(BAUDRATE);
}

/* Serial return codes:
    00-07: Mirror movement
    08-0F: DAC update
    10-17: LaserOn
    18-1F: LaserOff
    20: ------------------
    21: Serial received scan parameters
    22: Serial received modes
    23: Serial returned data
    24 + 0-3f (36d-99d): Serial received scan data + ID code
    64: Video frame triggered
    65: Video frame dropped (intentionally)
    
    fd: Serial alarm codes
    fe: Overtemperature alarm
    ff: Temp sample
*/
void queueSerialReturn(byte leadingByte, unsigned long timeStamp) {
  
    returnData[retDataIdxH] = leadingByte;
    returnTimes[retDataIdxH] = timeStamp;
    retDataIdxH++; retDataIdxH %= STORAGESIZE;
    retDataIdxGap++; 
    if (retDataIdxGap >= (STORAGESIZE)) {
      catchError(STORAGEFULL);
    }
}

// Receives serial transmissions once the Serial buffer is full enough
// The first byte should tell the size of the serial transmission
void receiveSerial() {
  
  byte i;
  byte msb;
  byte lsb;
  byte byte1;
  byte byte2;
  byte byte3;
  byte transmissionID;
 
  transmissionSize = Serial.read();
  
  if (transmissionSize == POSPOWERSIZE) {
    transmissionID = Serial.read();
    Serial.readBytes(((char *) Xpositions), 16);
    Serial.readBytes(((char *) Ypositions), 16);
    Serial.readBytes(((char *) LaserPowersBuffer),8);   
    DACsLeftToUpdate = numZones;
    nextDACIndex = (zoneIndex + 2) % numZones;
    lastComputerContact = prevTimePoint;
    queueSerialReturn(0x24 + transmissionID, prevTimePoint);
    // If the max-temperature flag is tripped, keep the mirrors locked.
    if (tempLock) {
      sleepMode();
    }
    
  } else if (transmissionSize == SCANPARAMSIZE) {
    msb = Serial.read();
    lsb = Serial.read();
    scanTime = (msb << 8) + lsb;
    halfTime =  ((unsigned long) scanTime) << 3;
    for (i=0; i < 8; i ++) {
      msb = Serial.read();
      lsb = Serial.read();
      mirrorMoveTime[i] = (msb << 8) + lsb;
    }
    Serial.readBytes(((char *) ScanOrder), 8);
    numZones = Serial.read();
    queueSerialReturn(0x21, prevTimePoint);
    
  } else if (transmissionSize == MODEPARAMSIZE) {
    
    byte1 = Serial.read();
    byte2 = Serial.read();
    byte3 = Serial.read();
    mode = byte1 & 7;
    
    // Mode 1: Laser watchdog test
    if (mode == 1) {
          // Turn on the laser
          LASERPINON;
          phase = 3;
          nextTimeGap = (((unsigned long) byte2) << 14);  // (Approximately ms)
    
    // Mode 2: Latency measurement mode  
    } else if (mode == 2) {
      if (byte2 > 0) {
        LASERPINON;
      } 
      mode = 0;
    } else if (mode == 3) {
      mode = 0;
      dropFrames = byte2;
    // Mode 4: Pulsed stimulation
    } else if (mode == 4) {  
      mode = 0;
      pulsePeriod = byte2;  
    } else if (mode == 5) {
      pulsePeriod = byte2;
    }
    queueSerialReturn(0x22, prevTimePoint);
    
  } else {
  
      // All serial frame errors should be caught by hardware buffer overwrite checking now.
      // Otherwise, there's been a mistake.
      byte1 = 0;
      // Throw away bytes until we find a possible POSPOWERSIZE frame to try to recover
      while ((Serial.peek() != POSPOWERSIZE) && (Serial.available() > 0) && (byte1 < 40)) {
        byte1++;
        byte2 = Serial.read();
      }
      // Throw an error back
      queueSerialReturn(0xfd, ((unsigned long) transmissionSize) << 8);
  }
  
  
}

