// Phase 0 is End of lasing until mirror movement 
void phase0() {
    // Find the next zone and output it
    SETCURRENTZONE;  // Outputs current zone address
    pT.restoreInterrupts();
    laserDuration = (((unsigned long) LaserPowers[currentZone]) * ((((unsigned long) scanTime) << 4) - LASERENDPAD)) << 8;  
    nextTimeGap = ((unsigned long) mirrorMoveTime[currentZone]) << 4;
    if (laserDuration == 0) {
      pT.queueNextEvent(nextTimeGap, phase3);
    } else {
      pT.queueNextEvent(nextTimeGap, phase1);
      queueSerialReturn(0x10 + currentZone, pT.eventTime + nextTimeGap);                  // Denotes laser on.  Do this in advance in case of short laser epochs.
      queueSerialReturn(0x18 + currentZone, pT.eventTime + nextTimeGap + laserDuration);  // Denotes laser off.
    }    
    
}
