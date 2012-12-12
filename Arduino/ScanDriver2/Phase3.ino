// Phase 3 is an epoch without any lasing
void phase3() {
        pT.restoreInterrupts();
//        LASERPINOFF;
        mode = 0;   // Needed to recover from watchdog test mode
        nextTimeGap = ((unsigned long) scanTime) << 4;    
                    
        // Update zone here for speed at start of phase 0
        zoneIndex++;
        if (zoneIndex >= numZones) {zoneIndex = 0;}
        currentZone = ScanOrder[zoneIndex]; 
        // queueSerialReturn(0x00 + currentZone, prevTimePoint + nextTimeGap);  // Denotes mirror movement.
        pT.queueNextEvent(nextTimeGap, phase0);
        checkForTransfers();
}
