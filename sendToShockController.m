function sendToShockController(byte1,byte2)

	global USBshockController;

	list = [2, byte1, byte2];

	if strcmp(USBshockController.TransferStatus,'idle')
		fwrite(USBshockController, [uint8(list)],  'uint8','async');
	else
		disp('Failed write to ShockController.');
	end
