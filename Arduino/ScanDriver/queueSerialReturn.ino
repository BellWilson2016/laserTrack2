void queueSerialReturn(byte leadingByte, unsigned long timeStamp) {
  
    returnData[retDataIdxH] = leadingByte;
    returnTimes[retDataIdxH] = timeStamp;
    retDataIdxH++;
    retDataIdxGap++;
    if (retDataIdxH >= STORAGESIZE) { retDataIdxH = 0; }  
}
