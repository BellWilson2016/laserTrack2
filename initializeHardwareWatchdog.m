function USBwatchdog = initializeHardwareWatchdog()

	global USBwatchdog;

    portLocation = '/dev/ttyACM0';  

    USBwatchdog = serial(portLocation);
    USBwatchdog.BaudRate=115200;   
           
    fopen(USBwatchdog);
    pause(.5);
    % Need to pause for bootloader before MCU starts listening
    % Board resets on opening serial connections.
    
    disp(['USBwatchdog initialized on ', portLocation]); 

