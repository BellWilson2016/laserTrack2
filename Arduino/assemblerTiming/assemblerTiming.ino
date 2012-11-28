#define SERIALPINON  PORTD |= B00001000;
#define SERIALPINOFF PORTD &= B11110111;

volatile byte delayTime;

void setup() {
  
  pinMode(3, OUTPUT);
  delayTime = 1;
  
}

void loop() {

 unsigned char sreg;
 sreg = SREG; 
 cli();
 SERIALPINON 
 asm volatile(  "ldi r30, pm_lo8(end)    \n\t"   
                "ldi r31, pm_hi8(end)    \n\t" 
                "sub r30, %[delay]   \n\t"
                "sbc r31, __zero_reg__  \n\t"
                "ijmp                 \n\t"
            "begin:                   \n\t" 
               "nop                   \n\t" 
               "nop                   \n\t" 
               "nop                   \n\t" 
               "nop                   \n\t" 
               "nop                   \n\t" 
               "nop                   \n\t" 
               "nop                   \n\t" 
               "nop                   \n\t" 
             "end:                    \n\t"
            :
            : [delay] "r" (delayTime)
            :
            "r30","r31");
SERIALPINOFF
SREG = sreg;
  
}
