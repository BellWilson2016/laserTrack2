void setupUTimer() {
  
  unsigned char sreg;               // System registers for timer disabling
  
  // Disable timer during setup 
  TIMSK1 &= ~(1<<TOIE1);  
  
  // Configure timer in normal mode (pure counting, no PWM etc.)
  TCCR1A &= ~((1<<WGM11) | (1<<WGM10));  
  TCCR1A &= ~((1<<COM1A1)|(1<<COM1A0)|(1<<COM1B1)|(1<<COM1B0));
  TCCR1B &= ~((1<<WGM12)|(1<<WGM13));  
  TCCR1B &= ~((1<<FOC1A)|(1<<FOC1B));
   
  // Disable Compare Match interrupt enable (only want overflow) 
  TIMSK1 &= ~((1<<OCIE1A) | (1<<OCIE1B));  
  
  /* Select clock source: internal I/O clock */ 
  //ASSR &= ~(1<<AS2); 
  
  // Set prescaler to CPU clock divided by 1 
  TCCR1B &=   ~(7);
  TCCR1B |=   (0<<CS12)|(0<<CS11)|(1<<CS10); 

  
  // Disable interrupts, write timer to zero
  sreg = SREG;
  cli();
  TCNT1 = 0;
  SREG = sreg;
  
  uTimerOverflows = 0;

  // Enable timer
  TIMSK1 |= (1<<TOIE1); 

}
