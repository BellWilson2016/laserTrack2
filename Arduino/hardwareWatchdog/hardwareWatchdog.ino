#include  "pinDefs.h"
#define   ARMSWITCHON  !digitalRead(SWITCHINPIN)

byte     thermPhase = 0;
byte     nThermPhases = 15;
int      lastMirrorTemp = (25 << 4); // Start these in range to prevent faults on boot.
int        lastRoomTemp = (25 << 4);
volatile boolean   computerSane = true;
volatile boolean      supplySane = true;
boolean          tempOK;
int       highTempLimit = (35 << 4);
int        lowTempLimit = (15 << 4);
boolean   deviceLocked;
boolean   debugMode = false;
byte      debugCode;
unsigned long lastTransmitTime;         // ms
unsigned long transmitInterval = 5000;  // ms
unsigned long lastDACUpdateTime;
unsigned long maxDACInterval = 5000;    // ms
byte statusByte;

void setup() {
  
  setupPins();

  Serial.begin(115200);
  setupThermometer(MIRRORTHERMPIN);  
  setupThermometer(  ROOMTHERMPIN);
  
  if (debugMode) {
    Serial.println("Debug mode ON.");
  }
  
  attachInterrupt(0,         supplyInsane, CHANGE);
  attachInterrupt(1, computerInsaneToggle, CHANGE);

  deviceLocked = false;
  computerSane = digitalRead(  COMPSANEPIN);
    supplySane = digitalRead(SUPPLYSANEPIN);  
  tempOK = true;
  if (ARMSWITCHON) {
    if (debugMode) {
      Serial.println("Armed at reboot.");
    }
    lockdownDevice();
  }
  
  lastTransmitTime = millis();
  lastDACUpdateTime = millis();
   
}

void loop() {
  
    // Read the thermometer periodically
    if (thermPhase == 0) {
      startThermometerRead(MIRRORTHERMPIN);
      startThermometerRead(  ROOMTHERMPIN);
    } else if (thermPhase == nThermPhases) { 
      lastMirrorTemp = finishThermometerRead(MIRRORTHERMPIN);
      lastRoomTemp   = finishThermometerRead(  ROOMTHERMPIN);
    }    
    delay(50);
    thermPhase++;
    if (thermPhase > nThermPhases) {thermPhase = 0;}
    
    if ((lastMirrorTemp < lowTempLimit) || (lastMirrorTemp > highTempLimit) || (lastRoomTemp < lowTempLimit) || (lastRoomTemp > highTempLimit)) {
      if (debugMode) {
          Serial.println("Temp fault.");
       }
      tempOK = false;
    } else {
      tempOK = true;
    }
    
    // Check to make sure we don't need to reset the interrupts
    checkComputerSane();
    supplyInsane();   

    if (ARMSWITCHON) {
        if (tempOK && computerSane && supplySane) {
          digitalWrite(LASERPOWERPIN, HIGH);
          digitalWrite(ARMLEDPIN,     HIGH);
        } else {
          lockdownDevice();
        }
    } else {
        digitalWrite(LASERPOWERPIN, LOW);
        digitalWrite(ARMLEDPIN,     LOW);
        if (tempOK && supplySane && computerSane) {
          digitalWrite(FAULTLEDPIN, LOW);
        } else {
          digitalWrite(FAULTLEDPIN, HIGH);
        }
    }
    
    checkToTransmit();
    

}

// Transmits if it's time
void checkToTransmit() {
  
    if ((long) (millis() - (lastTransmitTime + transmitInterval)) > 0) {
      lastTransmitTime = millis();
      statusByte = (deviceLocked << 0) + (!computerSane << 1) + (!supplySane << 2) + (!tempOK << 3);
      Serial.write(statusByte);
      Serial.write(lastMirrorTemp >> 8);
      Serial.write((lastMirrorTemp & 0x00FF));
      Serial.write(lastRoomTemp >> 8);
      Serial.write(lastRoomTemp & 0x00FF);
    }
  
}



void lockdownDevice() {
  
    deviceLocked = true;
    digitalWrite(MUTEMIRRORSPIN, HIGH);
    digitalWrite(LASERPOWERPIN,   LOW);
    digitalWrite(FAULTLEDPIN, HIGH);
    
    if (debugMode) {
      Serial.print("Locked down.");
    }
    delay(100);
    
    while (ARMSWITCHON) {
        digitalWrite(ARMLEDPIN, HIGH);
        delay(200);
        digitalWrite(ARMLEDPIN,  LOW);
        delay(200);
        if (debugMode) {
          Serial.print(".");
        }
        checkToTransmit();
    }
    checkComputerSane();
    supplyInsane();

    digitalWrite(MUTEMIRRORSPIN, LOW);
    digitalWrite(FAULTLEDPIN, LOW);
    deviceLocked = false;
    if (debugMode) {
      Serial.println(".");
      Serial.println("Escaped lockdown.");
    }
}


void computerInsaneToggle() {
      lastDACUpdateTime = millis();
      checkComputerSane();
}

void checkComputerSane() {
      if ((long) (millis() - (lastDACUpdateTime + maxDACInterval)) > 0) {
          computerSane = false;
      } else if (!ARMSWITCHON) {
          computerSane = true;
      }
}

void supplyInsane() {
      if (digitalRead(SUPPLYSANEPIN)) {
        if (!ARMSWITCHON) {
          supplySane = true; 
        }
      } else {
        supplySane = false;
      }  
}

