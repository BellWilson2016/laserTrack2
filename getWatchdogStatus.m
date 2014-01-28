function WDS = getWatchdogStatus()

	global USBwatchdog;
	
	% Probe by sending a value
	fwrite(USBwatchdog, uint8(0),  'uint8','async');
	
	% Wait for 5 bytes to come back
	while (USBwatchdog.BytesAvailable > 5)
		pause(.05);
	end
	
	statusByte = fread(USBwatchdog,1);
	mirrorTempMSB = fread(USBwatchdog,1);
	mirrorTempLSB = fread(USBwatchdog,1);
	roomTempMSB = fread(USBwatchdog,1);
	roomTempLSB = fread(USBwatchdog,1);
	
	WDS.mirrorTemp = ((mirrorTempMSB*256) + mirrorTempLSB)/16;
	WDS.roomTemp = ((roomTempMSB*256) + roomTempLSB)/16;
	WDS.deviceLocked = sign(bitand(statusByte,1));
	WDS.computerSane = 1 - sign(bitand(statusByte,2));
	WDS.supplySane   = 1 - sign(bitand(statusByte,4));
	WDS.tempOK       = 1 - sign(bitand(statusByte,8));
	
	% Clear any errant bytes
	while (USBwatchdog.BytesAvailable > 0)
		a = fread(USBwatchdog,1);
	end
		
