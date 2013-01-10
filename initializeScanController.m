%% initializeScanController() 
%
% nb. This causes an arduino reset
%
% JSB 11/2012
function USBscanController = initializeScanController()

global USBscanController;

    if ispc()
        portLocation = 'COM10';        
    elseif isunix()
        portLocation = '/dev/ttyACM0';  
    end
    USBscanController = serial(portLocation);
    USBscanController.BaudRate=115200;   
    

    set(USBscanController,'BytesAvailableFcn',@serialReceiver);
    set(USBscanController,'BytesAvailableFcnCount',5*64*100); % Was 5*64*1
    set(USBscanController,'BytesAvailableFcnMode','byte');
	% set(USBscanController,'ReadAsyncMode','manual');


	set(USBscanController,'InputBufferSize',5*64*200);
    % set(USBscanController,'Terminator',10);
    % set(USBscanController,'Timeout',.2);
        
    fopen(USBscanController);
    pause(2);
    % Need to pause for bootloader before MCU starts listening
    % Board resets on opening serial connections.
    
    disp(['ScanController initialized on ',portLocation]); 
    tic;





  


        
    




