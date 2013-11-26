function USBshockController = initializeShockController() 

	global USBshockController;

	if ispc()
        portLocation = 'COM10';        
    elseif isunix()
        portLocation = '/dev/ttyACM1';  
    end
    USBshockController = serial(portLocation);
    USBshockController.BaudRate=115200;   
           
    fopen(USBshockController);
    pause(2);
    % Need to pause for bootloader before MCU starts listening
    % Board resets on opening serial connections.
    
    disp(['ShockController initialized on ', portLocation]); 
    tic;
