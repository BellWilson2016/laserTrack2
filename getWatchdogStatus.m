function getWatchdogStatus()

	global USBwatchdog;
	
	fwrite(USBwatchdog, uint8(0),  'uint8','async');
