

// This function will lock the controller and pulse the DACPIN to signal an error
void DONOTOPTIMIZE catchError(int errorNumber) {
  
  int i;
  
  while (true) {
    cli();
    SERIALPINON;
    for (i=0; i < errorNumber; i++) {
      DACPINON;
      DACPINOFF;
      DACPINOFF;
    }
    SERIALPINOFF;
  }
}
