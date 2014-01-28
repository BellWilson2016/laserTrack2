function WDS = getWatchdogStatus()

	global USBwatchdog;
	
	
	% Probe by sending a value
	fwrite(USBwatchdog, uint8(0),  'uint8','async');
	
	% Wait for 5 bytes to come back
	while (USBwatchdog.BytesAvailable < 5)
		pause(.005);
	end
	
	tic();
	
	readBytes = fread(USBwatchdog,5);
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
	
	
	% Clear any errant bytes
	while (USBwatchdog.BytesAvailable > 0)
		a = fread(USBwatchdog,1);
	end
	
	toc
	
	if (WDS.deviceLocked || ~WDS.computerSane || ~WDS.supplySane || ~WDS.tempOK)
		WDS
		return;	
		notifyOfFault(['RTFW Hardware Watchdog detected fault. Status byte: ',num2str(WDS.statusByte),...
					   ' Mirror temp: ', num2str(WDS.mirrorTemp), ' Room temp: ', num2str(WDS.roomTemp),...
					   ' Reset DAQ. Cleared all timers.']);
				   
		jDAQmx.jDAQmxReset('Dev1');
		softReset();
	end
		
	
