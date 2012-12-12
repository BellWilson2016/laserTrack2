void checkForTransfers() {
//SERIALPINON;
  byte nTransfers;
  byte dataLoc;
  unsigned long aTime;
  byte n;
  int i,j;
  
      
  
      availableBytes = Serial.available();
      // If there's new serial data, get it.
      if ((availableBytes > 0) && (availableBytes >= Serial.peek())) {
         SERIALPINON;
          receiveSerial();
         SERIALPINOFF;   
      // If there's not, pass data to the next DAC  
      } else if (DACsLeftToUpdate > 0)  {
         
          if (currentZone != ScanOrder[nextDACIndex]) {
            DACPINON;
            passDataToDAC(ScanOrder[nextDACIndex]);
            DACsLeftToUpdate--;
            nextDACIndex = nextDACIndex + 1; 
            if (nextDACIndex >= numZones) {nextDACIndex = 0; } 
            DACPINOFF;
          }
      } else if (pT.eventTime - lastTemp > thermDelay)  {
          doThermometer();  
      } else if (retDataIdxGap > 10) {
          // If the dataGap is big, report it
          if (retDataIdxGap > STORAGESIZE - 20) {
              queueSerialReturn(0xfd, (unsigned long) retDataIdxGap);
          }
          // If there's space in the buffer...
          if (Serial.txBufferSpace() > 10*5) {     
            for (n=0; n < 10; n++) {
              // queueSerialReturn(0x23, prevTimePoint);
              // Don't send too many bytes
                SERIALPINON;
                dataLoc = (retDataIdxH - retDataIdxGap) % STORAGESIZE;
                aTime = returnTimes[dataLoc];
                Serial.write(returnData[dataLoc]);
                Serial.write((aTime >> 24)&0xFF);
                Serial.write((aTime >> 16)&0xFF);
                Serial.write((aTime >> 8)&0xFF);
                Serial.write((aTime >> 0)&0xFF);
                retDataIdxGap--;
                SERIALPINOFF;  
             }
           }    
     } else if (pT.eventTime - lastComputerContact > LOSTCONTACTTIME) {
          sleepMode();
     }

}

