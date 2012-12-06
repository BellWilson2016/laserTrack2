ISR(TIMER1_OVF_vect) {  

  // No need to reset TOV1, automatically happens on ISR
  uTimerOverflows++;
  
} 

