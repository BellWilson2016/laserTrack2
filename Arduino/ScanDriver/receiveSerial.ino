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
  
  // Serial check1
  if (UCSR0A & (1 << DOR0)) {
    while (true) {
      DACPINON;
      for (i=0; i < (phase + 1); i++) {
          SERIALPINON;
          SERIALPINOFF;
          SERIALPINOFF;
      }
      DACPINOFF;
    }
  }
  
  
  SYNC1PINON;
  SERIALPINON;
  
  transmissionSize = Serial.read();
  
  if (transmissionSize == POSPOWERSIZE) {
    transmissionID = Serial.read();
    Serial.readBytes(((char *) Xpositions), 16);
    Serial.readBytes(((char *) Ypositions), 16);
    Serial.readBytes(((char *) LaserPowers),8);   
    DACsLeftToUpdate = numZones;
    nextDACIndex = zoneIndex + 1;
    if (nextDACIndex >= numZones) {
      nextDACIndex = 0;
    }
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
    }
    queueSerialReturn(0x22, prevTimePoint);
    
  } else {
  
      // All serial frame errors should be caught by hardware buffer overwrite now.
      DACPINON;
      while (true) {
        NOP;
      }
      // Otherwise, there's been a mistake.
      byte1 = 0;
      // Throw away bytes until we find a possible POSPOWERSIZE frame to try to recover
      while ((Serial.peek() != POSPOWERSIZE) && (Serial.available() > 0) && (byte1 < 40)) {
        byte1++;
        byte2 = Serial.read();
      }
      // Throw an error back
      queueSerialReturn(0xfd, ((unsigned long) byte1) << 8);
  }
  
  SERIALPINOFF;
  SYNC1PINOFF;
  
}




