// Shock parameters
#define SHOCKLPIN 2
#define SHOCKRPIN 3
#define DEFAULTLENGTH 1250
#define DEFAULTPERIOD 5000

// Serial Port parameters
#define BAUDRATE 115200
#define TRANSSIZE 2

// Timer parameters
unsigned long prevTimePoint;
unsigned long nextTimeGap;
unsigned long timeNow;

int shockLength;
int shockPeriod;
boolean leftShock;
boolean rightShock;
byte availableBytes;
byte shockPhase;

void setup() {
  
  // Setup shock pins
  shockLength    = DEFAULTLENGTH;
  shockPeriod    = DEFAULTPERIOD;
  leftShock = false;
  rightShock = false;
  shockPhase = 0;
  pinMode(13, OUTPUT);
  pinMode(SHOCKLPIN, OUTPUT);
  pinMode(SHOCKRPIN, OUTPUT);
  digitalWrite(SHOCKLPIN, LOW);
  digitalWrite(SHOCKRPIN, LOW);
  
  setupSerial();
  
  prevTimePoint = millis();
  nextTimeGap = 0;
}

void loop() {
  
  timeNow = millis();
  if ((long) (timeNow - prevTimePoint) < nextTimeGap) {
  
    availableBytes = Serial.available();
    if (availableBytes > 2) {
      receiveSerial();
    }  
    
  } else {
    
    prevTimePoint += nextTimeGap;
        
    if (shockPhase == 0) {
      digitalWrite(13, HIGH);
      nextTimeGap = ((unsigned long) shockLength);
      if (leftShock) {
        digitalWrite(SHOCKLPIN, HIGH);
      }
      if (rightShock) {
        digitalWrite(SHOCKRPIN, HIGH);
      }
      shockPhase = 1;
    } else if (shockPhase == 1) {
      digitalWrite(13, LOW);
      nextTimeGap = ((unsigned long) shockPeriod) - ((unsigned long) shockLength);
      digitalWrite(SHOCKLPIN, LOW);
      digitalWrite(SHOCKRPIN, LOW);
      shockPhase = 0;
    }
    
  }
}


void setupSerial() {
  Serial.begin(BAUDRATE);
}


void receiveSerial() {
  
  byte transmissionSize;
  byte msb;
  byte lsb;
  unsigned int fullValue;
  byte code;
  
  transmissionSize = Serial.read();
  if (transmissionSize == TRANSSIZE) {
    msb = Serial.read();
    lsb = Serial.read();
    
    fullValue = (((unsigned int) msb) << 8) + ((unsigned int) lsb);
    code = fullValue & (0x07);
    fullValue = fullValue >> 3;
    

    
    if ((code & 0x05) == 0) {
      // Right off
      rightShock = false;
      if (shockPhase == 0) {
        digitalWrite(SHOCKRPIN, LOW);
      }
    } else if ((code & 0x05) == 1) {
      // Right on
      rightShock = true;
      if (shockPhase == 0) {
        digitalWrite(SHOCKRPIN, HIGH);
      }
    } 
    if ((code & 0x06) == 0) {
      // Left off
      leftShock = false;
      if (shockPhase == 0) {
        digitalWrite(SHOCKLPIN, LOW);
      }
    } else if ((code & 0x06) == 2) {
      // Left on
      leftShock = true;
      if (shockPhase == 0) {
        digitalWrite(SHOCKLPIN, HIGH);
      }
    } 
    
    if ((code & 0x07) == 5) {
      shockLength = fullValue;
      if (shockPhase == 0) {
        nextTimeGap = ((unsigned long) shockLength);
      }
    } else if ((code & 0x07) == 6) {
      shockPeriod = fullValue;
      if (shockPhase == 1) {
        nextTimeGap = ((unsigned long) shockPeriod) - ((unsigned long) shockLength);
      }
    }
    
  } else { 
    
    // Try to recover from serial errors?
    while ((Serial.peek() != TRANSSIZE) && (Serial.available() > 0)) {
      msb = Serial.read();
    }
  }
 
  
}
