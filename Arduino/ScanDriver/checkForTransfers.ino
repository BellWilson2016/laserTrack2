void checkForTransfers() {
  
  
  
  byte nTransfers;
  byte dataLoc;
  unsigned long aTime;
  byte n;
  int i,j;
  
  nTransfers = nextTimeGap / TRANSFERWINDOWSIZE;
  // Limit transfers to 1
  if (nTransfers > 1) { nTransfers = 1; }

  for (i=0; i < nTransfers; i++) {
      availableBytes = Serial.available();
      // If there's new serial data, get it.
      if ((availableBytes > 0) && (availableBytes >= Serial.peek())) {
          receiveSerial();
      // If there's not, pass data to the next DAC  
      } else if (DACsLeftToUpdate > 0) {
          passDataToDAC(ScanOrder[nextDACIndex]);
          DACsLeftToUpdate--;
          nextDACIndex = nextDACIndex + 1; 
          if (nextDACIndex >= numZones) {nextDACIndex = 0; }
          
      } else if (timeNow - lastTemp > thermDelay) {
         doThermometer();
      } else if (retDataIdxGap > 6) {
         
          // If the dataGap is big, report it
          if (retDataIdxGap > 64) {
            queueSerialReturn(0xfd, (unsigned long) retDataIdxGap);
          }
              
          for (n=0; n < 6; n++) {
            // queueSerialReturn(0x23, prevTimePoint);
            // Don't send too many bytes
            SERIALPINON;
              dataLoc = retDataIdxH - retDataIdxGap;
              aTime = returnTimes[dataLoc];
              Serial.write(returnData[dataLoc]);
              Serial.write((aTime >> 24)&0xFF);
              Serial.write((aTime >> 16)&0xFF);
              Serial.write((aTime >> 8)&0xFF);
              Serial.write((aTime >> 0)&0xFF);
              retDataIdxGap--;
            SERIALPINOFF;
          }    
     } else if (prevTimePoint - lastComputerContact > LOSTCONTACTTIME) {
          sleepMode();
     }
  }
  
  
  
}


