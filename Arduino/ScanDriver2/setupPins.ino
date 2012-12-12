void setupPins() {
   pinMode(SERIALSYNCPIN, OUTPUT); digitalWrite(SERIALSYNCPIN, LOW);
   pinMode(DACSYNCPIN, OUTPUT);    digitalWrite(DACSYNCPIN, LOW);
   pinMode(LASERPIN, OUTPUT);      digitalWrite(LASERPIN, LOW);
   pinMode(SYNC1PIN, OUTPUT);      digitalWrite(SYNC1PIN, LOW);
   pinMode(SYNC2PIN, OUTPUT);      digitalWrite(SYNC2PIN, LOW);
   pinMode(A0PIN, OUTPUT); 
   pinMode(A1PIN, OUTPUT);
   pinMode(A2PIN, OUTPUT);
   pinMode(CLRPIN, OUTPUT);
   pinMode(XLDACPIN, OUTPUT);
   pinMode(YLDACPIN, OUTPUT);
}
