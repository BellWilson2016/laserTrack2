function setScanMode(vals)

global USBscanController;
global trackingParams;

list = [3,vals];

% If the mirrors are off, transmit away
if ~trackingParams.scanMirrors
			fwrite(USBscanController, [uint8(list)],  'uint8','async');
% Otherwise, queue it for transmission along with position data
% This seems to be necessary to prevent serial collisions in MATLAB
else
	trackingParams.queuedData = [trackingParams.queuedData,list];
end



