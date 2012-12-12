#define SERIALSENDBLOCK 8

void checkForTransfers() {
  
//SERIALPINON;
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
       DACPINON;
       //SERIALPINON;
          passDataToDAC(ScanOrder[nextDACIndex]);
          LaserPowers[ScanOrder[nextDACIndex]] = LaserPowersBuffer[ScanOrder[nextDACIndex]];
       //SERIALPINOFF;   
       DACPINOFF;
          DACsLeftToUpdate--;
          nextDACIndex = nextDACIndex + 1; 
          if (nextDACIndex >= numZones) {nextDACIndex = 0; }        
      } else if (timeNow - lastTemp > thermDelay) {
       // DACPINON;
       //SERIALPINON;
         doThermometer();  
       //SERIALPINOFF;
       // DACPINOFF;
      } else if (retDataIdxGap > SERIALSENDBLOCK)  {
          // If the dataGap is big, report it
          if (retDataIdxGap > 0xD0) {
            queueSerialReturn(0xfd, (unsigned long) retDataIdxGap);
          }
          // If there's space in the buffer...
          if (Serial.txBufferSpace() > SERIALSENDBLOCK*5) {     
            //SERIALPINON;
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
            //SERIALPINOFF;
          }    
     } else if (prevTimePoint - lastComputerContact > LOSTCONTACTTIME) {
          sleepMode();
     }
  }
//  SERIALPINOFF;
}

