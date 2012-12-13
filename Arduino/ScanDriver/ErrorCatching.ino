


// This function will lock the controller and pulse the DACPIN to signal an error
void DONOTOPTIMIZE catchError(int errorNumber) {
  
  int i;
  
  while (true) {
    cli();
    for (i=0; i < errorNumber; i++) {
      SERIALPINON;
      SERIALPINOFF;
      SERIALPINOFF;
    }
    i = 0;
    while (i < 20) {
      i++;
      NOP; NOP;
    }
  }
}

void sleepMode() {
  
    int n;
    
    // Set mirrors to midscale
    for (n=0; n < 8; n++ ) {
      Xpositions[2*n+0] = 0x80;
      Xpositions[2*n+1] = 0x80;
      Ypositions[2*n+0] = 0x80;
      Ypositions[2*n+1] = 0x80;
      LaserPowers[n] = 0;
      LaserPowersBuffer[n] = 0;
    }
    
    // Flag that the DACs need updating
    DACsLeftToUpdate = numZones;
    nextDACIndex = zoneIndex + 1;
    if (nextDACIndex >= numZones) {
          nextDACIndex = 0;
    }
}

