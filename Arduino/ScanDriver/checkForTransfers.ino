void checkForTransfers() {
//SERIALPINON;
  byte nTransfers;
  byte dataLoc;
  unsigned long aTime;
  byte n;
  int i,j;
  
  // Don't allow transfers of the same type in the same epoch
  boolean doneSerialRx = false;
  boolean doneDAC      = false;
  boolean doneSerialTx = false;
  boolean doneTherm    = false;

  nTransfers = nextTimeGap / TRANSFERWINDOWSIZE;
  // Limit transfers
  if (nTransfers > 1) { nTransfers = 1; }

  for (i=0; i < nTransfers; i++) {
      availableBytes = Serial.available();
      // If there's new serial data, get it.
      if ((availableBytes > 0) && (availableBytes >= Serial.peek()) && !doneSerialRx) {
         //SERIALPINON;
          receiveSerial();
         //SERIALPINOFF;
         doneSerialRx = true;
      // If there's not, pass data to the next DAC  
      } else if ((DACsLeftToUpdate > 0) && !doneDAC) {
         //DACPINON;
          passDataToDAC(ScanOrder[nextDACIndex]);
         //DACPINOFF;
          DACsLeftToUpdate--;
          nextDACIndex = nextDACIndex + 1; 
          if (nextDACIndex >= numZones) {nextDACIndex = 0; }  
          doneDAC = true;          
      } else if ((timeNow - lastTemp > thermDelay) && !doneTherm) {
         doThermometer();  
         doneTherm = true;  
      } else if ((retDataIdxGap > 10) & !doneSerialTx) {
          // If the dataGap is big, report it
          if (retDataIdxGap > 0xD0) {
            queueSerialReturn(0xfd, (unsigned long) retDataIdxGap);
          }
          // If there's space in the buffer...
          if (Serial.txBufferSpace() > 10*5) {     
            for (n=0; n < 10; n++) {
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
          doneSerialTx = true;
     } else if (prevTimePoint - lastComputerContact > LOSTCONTACTTIME) {
          sleepMode();
     }
  }
//  SERIALPINOFF;
}

