// Shock parameters
#define SHOCKLPIN 2
#define SHOCKRPIN 3
#define DEFAULTLENGTH 1250
#define DEFAULTPERIOD 5000

// Serial Port parameters
#define BAUDRATE 115200
#define TRANSSIZE 2

int shockLength;
int shockPeriod;
boolean leftShock;
boolean rightShock;
byte availableBytes;

void setup() {
  
  // Setup shock pins
  shockLength    = DEFAULTLENGTH;
  shockPeriod    = DEFAULTPERIOD;
  leftShock = false;
  rightShock = false;
  pinMode(SHOCKLPIN, OUTPUT);
  pinMode(SHOCKRPIN, OUTPUT);
  digitalWrite(SHOCKLPIN, LOW);
  digitalWrite(SHOCKRPIN, LOW);
  
  setupSerial();
}

void loop() {
  
  availableBytes = Serial.available();
  if ((availableBytes > 0) && (availableBytes >= Serial.peek())) {
    receiveSerial();
  }  
}


void setupSerial() {
  Serial.begin(BAUDRATE);
}


void receiveSerial() {
  
  byte transmissionSize;
  byte msb;
  byte lsb;
  int fullValue;
  byte code;
  
  transmissionSize = Serial.read();
  if (transmissionSize == TRANSSIZE) {
    msb = Serial.read();
    lsb = Serial.read();
  } else {
    // Try to recover from serial errors?
    while ((Serial.peek() != TRANSSIZE) && (Serial.available() > 0)) {
      msb = Serial.read();
    }
  }
  
  fullValue = (((int) msb) << 8) + ((int) lsb);
  code = fullValue & (0x07);
  fullValue = fullValue >> 3;
  
  if ((code & 0x05) == 0) {
    // Right off
    rightShock = false;
  } else if ((code & 0x05) == 1) {
    // Right on
    rightShock = true;
  } 
  if ((code & 0x06) == 0) {
    // Left off
    leftShock = false;
  } else if ((code & 0x06) == 2) {
    // Left on
    leftShock = true;
  } 
  if ((code & 0x07) == 5) {
    shockLength = fullValue;
  } else if ((code & 0x07) == 6) {
    shockPeriod = fullValue;
  }
 
  
}
