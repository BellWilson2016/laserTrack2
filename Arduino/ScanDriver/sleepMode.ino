void sleepMode() {
  
    int n;
    
    // Set mirrors to midscale
    for (n=0; n < 8; n++ ) {
      Xpositions[2*n+0] = 0x80;
      Xpositions[2*n+1] = 0x80;
      Ypositions[2*n+0] = 0x80;
      Ypositions[2*n+1] = 0x80;
      LaserPowers[n] = 0;
    }
    
    // Flag that the DACs need updating
    DACsLeftToUpdate = numZones;
    nextDACIndex = zoneIndex + 1;
    if (nextDACIndex >= numZones) {
          nextDACIndex = 0;
    }
}
