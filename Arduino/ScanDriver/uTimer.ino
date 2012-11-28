// Nb. Interrupts should be off for this!
unsigned long uTimer() {
  
    unsigned int currentTime;
    unsigned long overflows;
    unsigned long output;
    rollFlag = false;    // Keep rollFlag global to allow testing of overflow handling duration
  
    currentTime = TCNT1;
    overflows = uTimerOverflows;
   
    // If the timer overflow bit is set, we missed an overflow 
    if ((TIFR1 & (1<<TOV1)) && (currentTime < 0xFFF5)) {
      overflows++;
      rollFlag = true;
    }    
    output = ((overflows << 16) + ((unsigned long) currentTime));
    if (rollFlag) {
      output += 13; // 13 is right!
    }
  return output;
  
}
