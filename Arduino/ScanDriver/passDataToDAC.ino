// This sends the data to the DACs over I2C
// DACs are set to update synchronously with the transfer
// This does transfers for the given address in X and Y
void passDataToDAC(byte addr) {
  
  byte command[3];
  
  DACPINON;
  command[0] = WRITECODE | addr;
  Wire.beginTransmission(XDACADDR);
    command[1] =  Xpositions[2*addr + 0];
    command[2] =  Xpositions[2*addr + 1];
    Wire.write(command, 3);
  Wire.endTransmission();
  Wire.beginTransmission(YDACADDR);
    command[1] =  Ypositions[2*addr + 0];
    command[2] =  Ypositions[2*addr + 1];
    Wire.write(command, 3);
  Wire.endTransmission();
  // queueSerialReturn(0x08 + addr, prevTimePoint);  
  DACPINOFF;
}
