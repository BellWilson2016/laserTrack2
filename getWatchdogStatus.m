function WDS = getWatchdogStatus()

	global USBwatchdog;
	
	% If there aren't bytes on the port we've lost connection with the watchdog.
	if (USBwatchdog.BytesAvailable < 5)		
		WDS = [];
		notifyOfFault('RTFW Hardware Watchdog Not Transmitting. ResetDAQ. Cleared all timers.');
		jDAQmx.jDAQmxReset('Dev1');
		softReset();
		return;
	end
	
	% Get the most recent bytes on the port
	while (USBwatchdog.BytesAvailable >= 5)
		readBytes = fread(USBwatchdog,5);
	end
	
	statusByte = readBytes(1);
	mirrorTempMSB = readBytes(2);
	mirrorTempLSB = readBytes(3);
	roomTempMSB = readBytes(4);
	roomTempLSB = readBytes(5);
	
	WDS.statusByte = statusByte;
	WDS.mirrorTemp = ((mirrorTempMSB*256) + mirrorTempLSB)/16;
	WDS.roomTemp = ((roomTempMSB*256) + roomTempLSB)/16;
	WDS.deviceLocked = sign(bitand(statusByte,1));
	WDS.computerSane = 1 - sign(bitand(statusByte,2));
	WDS.supplySane   = 1 - sign(bitand(statusByte,4));
	WDS.tempOK       = 1 - sign(bitand(statusByte,8));
	
	if (WDS.deviceLocked)
		WDS
		notifyOfFault(['RTFW Hardware Watchdog detected fault. Status byte: ',num2str(WDS.statusByte),...
					   ' Mirror temp: ', num2str(WDS.mirrorTemp), ' Room temp: ', num2str(WDS.roomTemp),...
					   ' Reset DAQ. Cleared all timers.']);	   
		jDAQmx.jDAQmxReset('Dev1');
		softReset();
	end
		
	
