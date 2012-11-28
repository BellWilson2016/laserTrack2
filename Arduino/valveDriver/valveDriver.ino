// Valve outs on 3,4,5,6
#define VALVE1 3
#define VALVE2 4
#define VALVE3 5
#define VALVE4 6

void setup() {
  
  pinMode(VALVE1, OUTPUT);
  pinMode(VALVE2, OUTPUT);
  pinMode(VALVE3, OUTPUT);
  pinMode(VALVE4, OUTPUT);
  
  digitalWrite(VALVE1, HIGH);
  digitalWrite(VALVE2, LOW);
  digitalWrite(VALVE3, LOW);
  digitalWrite(VALVE4, HIGH);
  
}

void loop() {
}
