void terminalBlink() {
  
    while(true) {
      digitalWrite(ARMLIGHTPIN, HIGH);
      delay(200);
      digitalWrite(ARMLIGHTPIN, LOW);
      delay(200);
    }  
}


  
