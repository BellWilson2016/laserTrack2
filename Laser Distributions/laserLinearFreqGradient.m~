function returnPower = laserLinearFreqGradient(args)  

	global trackingParams;

    leftF  = args(1);
    rightF = args(2);
	Fgrad = (rightF - leftF)/50;  		% Power units / mm

	returnF = leftF + (trackingParams.bodyX + trackingParams.headX + 25).*Fgrad;    
	
	ix = find(returnF < 0);
	returnF(ix) = 0;

	returnPower = round(256 - 1./(.01.*returnF));



