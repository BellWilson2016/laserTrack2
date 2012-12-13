//
// LaserWatchdog
//
// This sketch is designed to protect against laser over-powering.  It controls a solid-state relay
// which applies power to the laser.  The ARM button must be OFF when the system is booted, or it will
// trigger an alarmTripped condition.  The alarmTripped condition can be cleared by turning off the ARM button.
//
// After the system boots, pressing the ARM button turns on the SSR.  The sketch then samples the laser 
// command every 50 microseconds, and stores the result into a ring buffer that refills every 100 ms. 
// If the laser is on for more than THRESH % during this time, faultTripped -> TRUE, and the SSR
// is turned off and locked.  Again, to clear the alarmTripped condition, the ARM button must be turned off.  
// 


#define LASERCMDPIN    2     // Laser command signal input
#define SSRPIN         3     // Controls relay to cut laser power
#define DISARMPIN      4     // Input from laser arming switch
#define ARMLIGHTPIN    5     // Controls arming indicator light
#define FAULTLIGHTPIN  6     // Controls alarm light
#define DRIVERFAULTPIN 7     // Mirror Driver drives LOW on fault

#define SAMPLEPERIOD    50u    // In us,
#define RINGBUFFERSIZE  250u   // In bytes.  400 us/byte x 250 bytes = 100 ms in 2000 samples 
#define THRESH          90u    // % Duty cycle over sample interval to trigger a fault


unsigned long lastSample;      // Time of last sample

boolean       armed;
boolean       SSR;
boolean       faultTripped;
boolean       driverFault;

byte          ringBuffer[RINGBUFFERSIZE];
unsigned int  currentTotal;
unsigned int  currentIndex;
unsigned int  totalSamples;
unsigned int  threshSamples;


void setup() {
    
  pinMode(LASERCMDPIN, INPUT);
  pinMode(SSRPIN, OUTPUT);
  pinMode(DISARMPIN, INPUT);
  pinMode(ARMLIGHTPIN, OUTPUT);
  pinMode(FAULTLIGHTPIN, OUTPUT);
  pinMode(DRIVERFAULTPIN, INPUT);
  
  digitalWrite(SSRPIN, LOW);
  digitalWrite(DISARMPIN, HIGH);       // Set pull-up resistor on
  digitalWrite(ARMLIGHTPIN, LOW);
  digitalWrite(FAULTLIGHTPIN, LOW);
  
  // Initialize ringBuffer to zero
  for (unsigned int ringPos = 0; ringPos < RINGBUFFERSIZE; ringPos++) {
    ringBuffer[ringPos] = 0;
  }
  // Sample counts for total samples and threshold
  totalSamples = RINGBUFFERSIZE*8;
  threshSamples = (((long) totalSamples)*THRESH)/(100ul);
  currentTotal = 0;
  
  // Setup as initially unarmed, untripped
  armed = false;
  SSR = false;
  faultTripped = false;
  driverFault = false;
  
  // Wait for other systems to boot and settle
  delay(200);                      
  
  armed = !(digitalRead(DISARMPIN));
  driverFault = !(digitalRead(DRIVERFAULTPIN)); 
  // Trip the alarm if the laser is armed on system booting.
  if (armed || driverFault) {
    faultTripped = true;
    digitalWrite(FAULTLIGHTPIN, faultTripped);
    // Blink the arm light pin until disarmed
    while(faultTripped) {
      digitalWrite(ARMLIGHTPIN, HIGH);
      delay(200);
      digitalWrite(ARMLIGHTPIN, LOW);
      delay(200);
      // Proceed when arm switch is off
      armed = !digitalRead(DISARMPIN);
      driverFault = !(digitalRead(DRIVERFAULTPIN)); 
      if (!armed && !driverFault) {
          faultTripped = false;
      }
      digitalWrite(FAULTLIGHTPIN, faultTripped);
    }     
  }
  
  lastSample = micros();
}




void loop() {
  
  byte aByte;
  byte currentBitPlace;
  byte thisSample;
  

  // If it's been longer than the sample interval, make a new check
  if ((micros() - lastSample) >= SAMPLEPERIOD) {
    lastSample = micros();
    
    // Read the arming
    armed = !digitalRead(DISARMPIN);
    driverFault = !(digitalRead(DRIVERFAULTPIN)); 
    // Only turn on the SSR if it's armed and there's no fault.
    if (armed && !faultTripped && !driverFault) {
      SSR = true;
    } else {
      SSR = false;
    }  
    
    // Write states to hardware pins
    digitalWrite(ARMLIGHTPIN, armed);
    digitalWrite(FAULTLIGHTPIN, faultTripped);
    digitalWrite(SSRPIN, SSR);
    
    // Grab a sample
    thisSample = digitalRead(LASERCMDPIN);
    // Fetch a byte from the ring buffer
    aByte = ringBuffer[(currentIndex >> 3)];
    currentBitPlace = currentIndex & 7;
    // If the current bit is set, deduct it from the running total
    if ((aByte & (1 << currentBitPlace)) && (currentTotal > 0)) {
      currentTotal--;
    }           
    // If the bit we're going to put in the buffer is set, add it
    // to the running total
    if (thisSample == HIGH) {
      currentTotal++;
      aByte |= (1 << currentBitPlace);
    } else {
      aByte &= ~(1 << currentBitPlace);
    }
    // Store the modified byte back into the ring buffer
    ringBuffer[(currentIndex >> 3)] = aByte;
    // Increment the buffer index, wrap to 0 if necessary
    currentIndex++;
    if (currentIndex >= totalSamples) {
      currentIndex = 0;
    }    
  
  
     // If too many counts are set and we're armed, faultTripped
     if (((currentTotal > threshSamples) && (armed)) || driverFault) {    
       faultTripped = true;
       // Turn off the SSR
       SSR = false;
       digitalWrite(SSRPIN, SSR);
       // Pulse the fault light until disarmed
       while (faultTripped) {
          digitalWrite(FAULTLIGHTPIN, HIGH);
          delay(200);
          digitalWrite(FAULTLIGHTPIN, LOW);
          delay(200);
          // Cancel the fault if the arm button is disarmed
          armed = !digitalRead(DISARMPIN);
          driverFault = !(digitalRead(DRIVERFAULTPIN));
          if (!armed && !driverFault) {
            faultTripped = false;
          }
       }
     }
     
   }
 
}
