 void setupPins() {
 
  pinMode(   COMPSANEPIN, INPUT);      
  pinMode( SUPPLYSANEPIN, INPUT);    
  pinMode(MUTEMIRRORSPIN, OUTPUT);  digitalWrite(MUTEMIRRORSPIN, LOW);   
  pinMode(     UNUSEDPIN, OUTPUT);  digitalWrite(     UNUSEDPIN, LOW);    

  pinMode(MIRRORTHERMPIN, OUTPUT);  digitalWrite(MIRRORTHERMPIN, LOW);   
  pinMode(  DACUPDATEPIN, INPUT);     
  pinMode(  ROOMTHERMPIN, OUTPUT);  digitalWrite(  ROOMTHERMPIN, LOW);     
  pinMode(  VIDEOTRIGPIN, INPUT);       

  pinMode( LASERPOWERPIN, OUTPUT);  digitalWrite( LASERPOWERPIN, LOW);    

  pinMode(   FAULTLEDPIN, OUTPUT);  digitalWrite(   FAULTLEDPIN, LOW);      
  pinMode(     ARMLEDPIN, OUTPUT);  digitalWrite(     ARMLEDPIN, LOW);       
  pinMode(  SWITCHOUTPIN, OUTPUT);  digitalWrite(  SWITCHOUTPIN, LOW);       
  pinMode(   SWITCHINPIN, INPUT_PULLUP);
  
 }
