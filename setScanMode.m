function setScanMode(vals)

global USBscanController;

list = [3,vals];

    % Write them all to USB if idle, otherwise drop
    transmitted = false;
    while ~transmitted

		if strcmp(USBscanController.TransferStatus,'idle')  && (USBscanController.BytesToOutput == 0)
			fwrite(USBscanController, [uint8(list)],  'uint8','async');
			transmitted = true;
		end
    end
