/* Serial return codes:
    00-07: Mirror movement
    08-0F: DAC update
    10-17: LaserOn
    18-1F: LaserOff
    20: ------------------
    21: Serial received scan parameters
    22: serial received modes
    23: Serial returned data
    24 + 0-3f (24-73): Serial received scan data + ID code
    
    fe: Overtemperature alarm
    ff: Temp sample
*/
void queueSerialReturn(byte leadingByte, unsigned long timeStamp) {
  
    returnData[retDataIdxH] = leadingByte;
    returnTimes[retDataIdxH] = timeStamp;
    retDataIdxH++;
    retDataIdxGap++;
    if (retDataIdxH >= STORAGESIZE) { retDataIdxH = 0; }  
}
