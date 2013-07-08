function setShockTiming(length, period)

	% Length and period in ms
	if (period < length)
		disp('Shock period less than length - not set.');
		return;
	end

	msb = uint8(bitshift(bitshift(length,3),-8));
	lsb = uint8(bitand(bitshift(length, 3),255) + 5);
	sendToShockController(msb,lsb);
	pause(.05);
	msb = uint8(bitshift(bitshift(period,3),-8));
	lsb = uint8(bitand(bitshift(period, 3),255) + 6);
	sendToShockController(msb,lsb);


