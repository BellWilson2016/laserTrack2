

// This function will lock the controller and pulse the DACPIN to signal an error
void DONOTOPTIMIZE catchError(int errorNumber) {
  
  int i;
  
  while (true) {
    cli();
    //SERIALPINON;
    NOP;
    for (i=0; i < errorNumber; i++) {
      DACPINON;
      DACPINOFF;
      DACPINOFF;
    }
    NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
    NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
    NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
    NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
    NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
    NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
    NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
    NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
    //SERIALPINOFF;
   
  }
}
