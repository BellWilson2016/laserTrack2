// Themometer is on A0
// Bus pull-up is on A1

#define PULLUPHI      PORTC |= B00000010
#define PULLUPLO      PORTC &= B11111101
#define PULLUPOUT     DDRC  |= B00000010

#define THERMOUT      DDRC  |= B00000001
#define THERMIN       DDRC  &= B11111110
#define THERMHI       PORTC |= B00000001
#define THERMLO       PORTC &= B11111110
#define THERMREAD     ((PINC &  B00000001)>>0)

void setup() {
  Serial.begin(115200);
  setupThermometer();
  
}

void loop() {
  
  int doubleTemp;
  byte b1,b2,b3,b4;
  
      thermReset();
      outNibble(0xcc,0,false);    // Skip ROM
      outNibble(0xcc,4,false);
      outNibble(0x44,0,false);    // Start conversion
      outNibble(0x44,4,true);
  
      delay(100);
  
      PULLUPLO;
      thermReset();
      outNibble(0xcc,0,false);    // Skip ROM
      outNibble(0xcc,4,false);
      outNibble(0xbe,0,false);    // Read scratchpad
      outNibble(0xbe,4,false);
  
      b1 = inNibble(0);
      b2 = inNibble(4);
      b3 = inNibble(0);
      b4 = inNibble(4);
   
      doubleTemp = (b1 >> 3) + (b2 >> 3) + (b3 << 5) + (b4 << 5);  
      Serial.print(doubleTemp/2);
      Serial.print(".");
      if (doubleTemp & 0x01) {
        Serial.println("5 C");
      } else {
        Serial.println("0 C");
      }
}



void setupThermometer() {
  
  byte b1, b2, b3, b4;
  
  
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

void thermReset() // reset.  Should improve to act as a presence pulse
{
     THERMLO;
     THERMOUT;
     delayMicroseconds(500);
     THERMIN;
     delayMicroseconds(500);
     delay(30);
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
  delay(30);
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
  
  delay(30);
  return(retByte);  
}
