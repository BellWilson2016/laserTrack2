#include  "pinDefs.h"
#define   ARMSWITCHON  !digitalRead(SWITCHINPIN)

byte     thermPhase = 0;
byte     nThermPhases = 15;
int      lastMirrorTemp = (25 << 4); // Start these in range to prevent faults on boot.
int        lastRoomTemp = (25 << 4);
boolean    computerSane = true;
boolean      supplySane = true;
boolean          tempOK;
int       highTempLimit = (35 << 4);
int        lowTempLimit = (15 << 4);
boolean   deviceLocked;
boolean   debugMode = false;
byte      debugCode;

void setup() {
  
  setupPins();

  Serial.begin(115200);
  setupThermometer(MIRRORTHERMPIN);  
  setupThermometer(  ROOMTHERMPIN);
  
  if (debugMode) {
    Serial.println("Debug mode ON.");
  }
  
  attachInterrupt(0, computerInsane, FALLING);

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
       
    supplySane = digitalRead(SUPPLYSANEPIN);
    if (!ARMSWITCHON) {
      computerSane = digitalRead(COMPSANEPIN); 
    }   
       
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
    
    if (Serial.available() > 0) {
      receiveCommunication();
    }

}

void receiveCommunication() {
      byte statusByte;
      statusByte = (deviceLocked << 0) + (!computerSane << 1) + (!supplySane << 2) + (!tempOK << 3);
      while (Serial.available() > 0) {
            debugCode = Serial.read();
      }
      if (debugMode) {
        Serial.println(debugCode);
        // "0"
        if (debugCode == 48) {
          Serial.println("Debug temp read:");
          printTemperature(MIRRORTHERMPIN, lastMirrorTemp);
          printTemperature(  ROOMTHERMPIN,   lastRoomTemp);
        } else if (debugCode == 49) {
          Serial.println(statusByte);
          Serial.println(lastMirrorTemp);
          Serial.println(lastRoomTemp);
        }
      } else {
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
        if (Serial.available() > 0) {
          receiveCommunication();
        }
        supplySane = digitalRead(SUPPLYSANEPIN);
        computerSane = digitalRead(  COMPSANEPIN);
    }

    digitalWrite(MUTEMIRRORSPIN, LOW);
    digitalWrite(FAULTLEDPIN, LOW);
    deviceLocked = false;
    if (debugMode) {
      Serial.println(".");
      Serial.println("Escaped lockdown.");
    }
}


void computerInsane() {
      computerSane = false;  
}


