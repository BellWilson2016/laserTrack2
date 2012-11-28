void setupDACs() {
  
  byte command[3];
  
  digitalWrite(CLRPIN, HIGH);   // Leave HIGH to prevent clearing
  digitalWrite(XLDACPIN, LOW);  // Leave LOW for synchronous updating with data transmission
  digitalWrite(YLDACPIN, LOW);
  
  Wire.begin();    // Start the I2C bus as Master  
  
  // Setup XDAC
  Wire.beginTransmission(XDACADDR);
    // Turn on internal reference on
    command[0] = B10000000;
    command[1] = 0;
    command[2] = 1;
    Wire.write(command, 3);
  Wire.endTransmission();
  Wire.beginTransmission(XDACADDR);
    // Clear-code set to mid-scale
    command[0] = B01010000;
    command[1] = 0;
    command[2] = B00000001;
    Wire.write(command, 3);
  Wire.endTransmission();
  // Set outputs to clear code
  digitalWrite(CLRPIN,LOW);
  digitalWrite(CLRPIN,HIGH);
  
  Wire.beginTransmission(XDACADDR);
    // Sets LDACs to synchronous, not pin controlled
    command[0] = B01100000;
    command[1] = 0;
    command[2] = B11111111;
    Wire.write(command, 3);
  Wire.endTransmission();
  Wire.beginTransmission(XDACADDR);
    // Power-down set to normal operation for all channels
    command[0] = B01000000;
    command[1] = 0;
    command[2] = B11111111;
    Wire.write(command, 3);
  Wire.endTransmission();

    // Setup YDAC
  Wire.beginTransmission(YDACADDR);
    // Turn on internal reference on
    command[0] = B10000000;
    command[1] = 0;
    command[2] = 1;
    Wire.write(command, 3);
  Wire.endTransmission();
  Wire.beginTransmission(YDACADDR);
    // Clear-code set to mid-scale
    command[0] = B01010000;
    command[1] = 0;
    command[2] = B00000001;
    Wire.write(command, 3);
  Wire.endTransmission();
  // Set outputs to clear code
  digitalWrite(CLRPIN,LOW);
  digitalWrite(CLRPIN,HIGH);
  
  Wire.beginTransmission(YDACADDR);
    // Sets LDACs to synchronous, not pin controlled
    command[0] = B01100000;
    command[1] = 0;
    command[2] = B11111111;
    Wire.write(command, 3);
  Wire.endTransmission();
  Wire.beginTransmission(YDACADDR);
    // Power-down set to normal operation for all channels
    command[0] = B01000000;
    command[1] = 0;
    command[2] = B11111111;
    Wire.write(command, 3);
  Wire.endTransmission();
  
}

