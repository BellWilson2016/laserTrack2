function returnPower = laserLinearFreqGradientY(args)  

	global trackingParams;

    leftF  = args(1);
    rightF = args(2);
	Fgrad = (rightF - leftF)/39;  		% Power units / mm

	returnF = leftF + (trackingParams.bodyY + trackingParams.headY + 39/2).*Fgrad;    
	
	ix = find(returnF < 0);
	returnF(ix) = 0;

	returnPower = round(256 - 1./(.01.*returnF));
	ix = find(returnPower < 0);
	returnPower(ix) = 0;




