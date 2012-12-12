// Phase 2 is laser ON until laser OFF
void phase2() { 
        LASERPINOFF;
        pT.restoreInterrupts();
        nextTimeGap = (((unsigned long) scanTime) << 4) - laserDuration;  // The amount of time left in the laser phase
        // Update zone here for speed at start of phase 0
        zoneIndex++;
        if (zoneIndex >= numZones) {zoneIndex = 0;}
        currentZone = ScanOrder[zoneIndex]; 
        // queueSerialReturn(0x00 + currentZone, prevTimePoint + nextTimeGap);  // Denotes mirror movement.   
        pT.queueNextEvent(nextTimeGap, phase0); 
        if (nextTimeGap > (475ul << 4)) {
          checkForTransfers();
        }
}
