function sendToShockController(args)

	byte1 = args{1};
	byte2 = args{2};

	global USBshockController;

	list = [2, byte1, byte2];

	if (bitand(byte2, 5) == 1)
		disp('-- L Shock ON --');
	else
		disp('-- L Shock OFF --');
	end
	if (bitand(byte2, 6) == 2)
		disp('-- R Shock ON --');
	else
		disp('-- R Shock OFF --');
	end

	if strcmp(USBshockController.TransferStatus,'idle')
		fwrite(USBshockController, [uint8(list)],  'uint8','async');
	else
		disp('Failed write to ShockController.');
	end
