
#define PULLUPHI      PORTC |= B00000010
#define PULLUPLO      PORTC &= B11111101
#define PULLUPOUT     DDRC  |= B00000010

#define THERMOUT      DDRC  |= B00000001
#define THERMIN       DDRC  &= B11111110
#define THERMHI       PORTC |= B00000001
#define THERMLO       PORTC &= B11111110
#define THERMREAD     ((PINC &  B00000001)>>0)

#define TEMPSHUTDOWN  (34 << 1)   // Define max and min temps
#define MINTEMP (15 << 1)         // Use a min temp to guard against 0 errors when disconnected

byte thermPhase;
byte b1,b2,b3,b4;
byte doubleTemp;


void doThermometer() {
  
  
  thermDelay = (1000 << 4); // Allow 500 us for the next step
  
  switch (thermPhase) {
    case 0:
      thermReset1();
      delayMicroseconds(400);
      thermReset2();
      break;
    case 1:
      outNibble(0xcc,0,false);    // Skip ROM
       break;
    case 2:
      outNibble(0xcc,4,false);
      break;
    case 3:
      outNibble(0x44,0,false);    // Start conversion
      break;
    case 4:
      outNibble(0x44,4,true);
      thermDelay = (200000 << 4); // Allow 100 ms for conversion
      break;
    case 5:
      PULLUPLO;
      thermReset1();
      delayMicroseconds(400);
      thermReset2();
      break;
    case 6:
      outNibble(0xcc,0,false);    // Skip ROM
      break; 
    case 7:  
      outNibble(0xcc,4,false);
      break;
    case 8:  
      outNibble(0xbe,0,false);    // Read scratchpad
      break;
    case 9:
      outNibble(0xbe,4,false); 
      break;
    case 10:
      b1 = inNibble(0);
     break;
    case 11:
      b2 = inNibble(4);
      break;
    case 12:
      b3 = inNibble(0);
       break;
    case 13:
      b4 = inNibble(4);
      break;
    case 14:
      doubleTemp = (b1 >> 3) + (b2 >> 3) + (b3 << 5) + (b4 << 5); 
      if ((doubleTemp >= TEMPSHUTDOWN) || (doubleTemp <= MINTEMP)) {
        // Lock the mirrors
        queueSerialReturn(0xfe,(unsigned long) doubleTemp);
        tempLock = true;
        sleepMode();
      } else {   
        queueSerialReturn(0xff,(unsigned long) doubleTemp);
      }
      thermDelay = 800000 << 4;  // Convert again in 1 second
      break;
  }
  
  lastTemp = prevTimePoint;
  // Increment the temp phase to run the next instruction
  thermPhase++; thermPhase %= 15;
  
}


void setupThermometer() {
  
  thermPhase = 0;
  tempLock = false;
  thermDelay = (500 << 4); // 500 us
  
  PULLUPOUT;
  PULLUPLO;
    
  THERMLO;
  THERMIN;
  thermReset();
  
  outNibble(0xcc,0,false);    // Skip ROM
  outNibble(0xcc,4,false);
  outNibble(0x4E,0,false);    // Write to scratchpad
  outNibble(0x4E,4,false);
  outNibble(0,0,false);       // Set Th
  outNibble(0,4,false);
  outNibble(0,0,false);       // Set TL
  outNibble(0,4,false);
  outNibble(0x1F,0,false);    // Set to 9 bits resolution
  outNibble(0x1F,4,false);
}

void thermReset() {
  thermReset1();
  delayMicroseconds(500);
  thermReset2();
  delayMicroseconds(500);
}

void thermReset1() {
     THERMLO;
     THERMOUT;
}
void thermReset2() {
     THERMIN;
}

void outNibble(byte aByte, byte half, boolean pullupOn) {
  
  byte n;
  
  for(n = half; n < (half + 4); n++) {
    THERMLO;
    THERMOUT;
    delayMicroseconds(2);
    if (((aByte & (0x01 << n)) >> n) == 0x01) {
      THERMHI;
    } else {
      THERMLO;
    }
    delayMicroseconds(60);
    if ((pullupOn) && (n == 7)) {
      THERMHI;
      PULLUPHI;
    } else {
      THERMIN;
      delayMicroseconds(2);
    }
  } 
} 

byte inNibble(byte half) {
  
  byte b,n;
  byte retByte = 0;
  
  for (n=half; n < half + 4; n++) {
    THERMLO;
    THERMOUT;
    delayMicroseconds(2);
    THERMIN;
    delayMicroseconds(15);
    b = THERMREAD;
    delayMicroseconds(60);
    retByte += (b << n);
  }
  
  return(retByte);  
}

