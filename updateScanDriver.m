%% updateScanDriver.m
%
% This outputs in terms of 16-bit DAC index numbers   
%
% JSB 11/2012
function transmissionID = updateScanDriver(xVals,yVals,pVals) 

    global USBscanController;   % The arduino to talk to
	global writeLock;
    
    % DAC calibrations to set zero at zero
    xPosCal = [69,92,3,-2,54,47,7,-61];
    yPosCal = [-17,11,16,75,-74,-213,-118,-160];
    
    % Make sure the size is correct
    pVals = zeros(1,8) + round(pVals);

    
    % Format a byte string
	transmissionID = randi(64)-1;
    XPos = byteBlock(xVals+xPosCal);
    YPos = byteBlock(yVals+yPosCal);
    list = [41,transmissionID,XPos,YPos,pVals];
    
    % Write them all to USB if idle, otherwise drop
	if strcmp(USBscanController.TransferStatus,'idle') && (USBscanController.BytesToOutput == 0)
		fwrite(USBscanController, [uint8(list)],  'uint8','async');
	else
			   % disp(['Serial collision: ',datestr(now)]);
			   % disp(USBscanController.BytesAvailable);
	end



    
