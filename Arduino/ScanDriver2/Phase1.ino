void phase1() {
    
  LASERPINON;
    
    int i;
    unsigned int coarseDelayTime;
    byte           fineDelayTime;  

    // For long pulses, go back through the counter
    if (laserDuration > (85 << 4)) {         
        pT.restoreInterrupts();
        nextTimeGap = laserDuration;
        pT.queueNextEvent(nextTimeGap, phase2);
        if (nextTimeGap > (475ul << 4)) {
          checkForTransfers();
        }
    // But for short pulses, delay a bit, then jump right to the next phase     
    } else {    
        // Calculate a non-negative delay
        if (laserDuration > 80) {
          coarseDelayTime = laserDuration - 80;    // Magic number to sync short laser times with long times
        } else { 
          coarseDelayTime = 0;
        }
        fineDelayTime   = (byte) coarseDelayTime & B00000111; 
        coarseDelayTime = coarseDelayTime >> 3;
        // Execute the delay 
        // .5 us per loop
        i = 0;
        while (i < coarseDelayTime) {
          i++;
          NOP;
          NOP;
        }
        // Cycle-accurate assembly delay
        asm volatile( "ldi r30, pm_lo8(endL)  \n\t"   
                      "ldi r31, pm_hi8(endL)  \n\t" 
                      "sub r30, %[delay]     \n\t"
                      "sbc r31, __zero_reg__ \n\t"
                      "ijmp                  \n\t"
                    "beginL:                  \n\t" 
                      "nop                   \n\t" 
                      "nop                   \n\t" 
                      "nop                   \n\t" 
                      "nop                   \n\t" 
                      "nop                   \n\t" 
                      "nop                   \n\t" 
                      "nop                   \n\t" 
                      "nop                   \n\t" 
                    "endL:                    \n\t"
                  :
                  : [delay] "r" (fineDelayTime)
                  :
                  "r30","r31");
       laserDuration = 0;  // Set to 0 to prevent epoch shortening
       phase2();
  }
}
