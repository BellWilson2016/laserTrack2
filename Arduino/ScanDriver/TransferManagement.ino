#define SERIALSENDBLOCK 8

void checkForTransfers() {
  
  byte dataLoc;
  unsigned long aTime;
  byte n;
  
  if (nextTimeGap > TRANSFERWINDOWSIZE) {
      availableBytes = Serial.available();
      // If there's new serial data, get it.
      if ((availableBytes > 0) && (availableBytes >= Serial.peek()))  {
        SERIALPINON;
          receiveSerial();
        SERIALPINOFF;
      // If there's not, pass data to the next DAC  
      } else if (DACsLeftToUpdate > 0)  {
          passDataToDAC(ScanOrder[nextDACIndex]);
          LaserPowers[ScanOrder[nextDACIndex]] = LaserPowersBuffer[ScanOrder[nextDACIndex]];
// On a new zero power, reset phase to 0
// * Don't do this.  Prevents boundary over-lasing
//          if (LaserPowers[ScanOrder[nextDACIndex]] == 0) {
//            LaserPhases[ScanOrder[nextDACIndex]] = 0;
//          }      
          DACsLeftToUpdate--;
          nextDACIndex++; nextDACIndex %= numZones;    
      } else if (timeNow - lastTemp > thermDelay) {
         doThermometer();  
      } else if (retDataIdxGap > SERIALSENDBLOCK)  {
          // If the dataGap is big, report it
          if (retDataIdxGap > 0xD0) {
            queueSerialReturn(0xfd, (unsigned long) retDataIdxGap);
          }
          // If there's space in the buffer...
          if (Serial.txBufferSpace() > SERIALSENDBLOCK*5) {     
            for (n=0; n < SERIALSENDBLOCK; n++) {
              // queueSerialReturn(0x23, prevTimePoint);
              // Don't send too many bytes

                dataLoc = retDataIdxH - retDataIdxGap;
                aTime = returnTimes[dataLoc];
                Serial.write(returnData[dataLoc]);
                Serial.write((aTime >> 24)&0xFF);
                Serial.write((aTime >> 16)&0xFF);
                Serial.write((aTime >> 8)&0xFF);
                Serial.write((aTime >> 0)&0xFF);
                retDataIdxGap--;
                
            }
          }    
     } else if (prevTimePoint - lastComputerContact > LOSTCONTACTTIME) {
          sleepMode();
     }
  }
}

