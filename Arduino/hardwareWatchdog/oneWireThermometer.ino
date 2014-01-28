#define PULLUPHI        digitalWrite(thermPin, HIGH)
#define PULLUPLO        digitalWrite(thermPin, LOW)
#define PULLUPOUT       pinMode(thermPin, OUTPUT)

#define  THERMOUT      pinMode(thermPin, OUTPUT)
#define  THERMIN       pinMode(thermPin, INPUT_PULLUP)
#define  THERMHI       digitalWrite(thermPin, HIGH)
#define  THERMLO       digitalWrite(thermPin, LOW)
#define  THERMREAD     digitalRead(thermPin)

void startThermometerRead(int thermPin) {

      thermReset(thermPin);
      outNibble(thermPin, 0xcc, 0, false);    // Skip ROM
      outNibble(thermPin, 0xcc, 4, false);
      outNibble(thermPin, 0x44, 0, false);    // Start conversion
      outNibble(thermPin, 0x44, 4, true);
      
}

// Nb. 12-bit conversion requires a minimum of 750 ms between
// the startThermometerRead() and finishThermomterRead()

int finishThermometerRead(int thermPin) {  
  
      int doubleTemp;
      byte b1,b2,b3,b4;
      
      PULLUPLO;
      thermReset(thermPin);
      outNibble(thermPin, 0xcc, 0, false);    // Skip ROM
      outNibble(thermPin, 0xcc, 4, false);
      outNibble(thermPin, 0xbe, 0, false);    // Read scratchpad
      outNibble(thermPin, 0xbe, 4, false);
      
  
      b1 = inNibble(thermPin, 0);
      b2 = inNibble(thermPin, 4);
      b3 = inNibble(thermPin, 0);
      b4 = inNibble(thermPin, 4);
   
      doubleTemp = (b1 >> 0) + (b2 >> 0) + (b3 << 8) + (b4 << 8); 

      return(doubleTemp);
}

void printTemperature(int thermPin, int doubleTemp) {
  
      int tempDecimal;
  
      if (thermPin == MIRRORTHERMPIN) {
        Serial.print("Mirror Temp: ");
      } else if (thermPin == ROOMTHERMPIN) {
        Serial.print("  Room Temp: ");
      }
      Serial.print(doubleTemp/16);
      Serial.print(".");
      tempDecimal = (doubleTemp & 0x0F) * 625;
      if (tempDecimal < 1000) {
        Serial.print(0);
      }
      if (tempDecimal < 100) {
        Serial.print(0);
        Serial.print(0);
      }
      Serial.println(tempDecimal);  
  
}

void setupThermometer(int thermPin) {
  
  byte b1, b2, b3, b4;
  
  
  PULLUPOUT;
  PULLUPLO;
  
  THERMLO;
  THERMIN;
  thermReset(thermPin);
  
  outNibble(thermPin, 0xcc, 0, false);    // Skip ROM
  outNibble(thermPin, 0xcc, 4, false);
  outNibble(thermPin, 0x4E, 0, false);    // Write to scratchpad
  outNibble(thermPin, 0x4E, 4, false);
  outNibble(thermPin,    0, 0, false);    // Set Th
  outNibble(thermPin,    0, 4, false);
  outNibble(thermPin,    0, 0, false);    // Set TL
  outNibble(thermPin,    0, 4, false);
  outNibble(thermPin, 0x7F, 0, false);    // Set resolution: was 9-bit @ 1F
  outNibble(thermPin, 0x7F, 4, false);    // 7F sets to 12-bit
}

void thermReset(int thermPin) // Reset.  Should improve to act as a presence pulse
{
     THERMLO;
     THERMOUT;
     delayMicroseconds(500);
     THERMIN;
     delayMicroseconds(500);
     delay(30);
}




void outNibble(int thermPin, byte aByte, byte half, boolean pullupOn) {
  
  byte n;
  
  noInterrupts();
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
  interrupts();
  delay(30);
} 



byte inNibble(int thermPin, byte half) {
  
  byte b,n;
  byte retByte = 0;
  
  noInterrupts();
  for (n=half; n < half + 4; n++) {
    THERMLO;
    THERMOUT;
    delayMicroseconds(2);
    THERMIN;
    delayMicroseconds(10); // Was 15
    b = THERMREAD;
    delayMicroseconds(60);
    retByte += (b << n);
  }
  interrupts();
  
  delay(30);
  return(retByte);  
}
