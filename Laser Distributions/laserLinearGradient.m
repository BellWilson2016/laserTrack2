function returnPower = laserLinearGradient(args)  

	global trackingParams;

    leftP  = args(1);
    rightP = args(2);
	Pgrad = (rightP - leftP)/50;  		% Power units / mm

	returnPower = leftP + (trackingParams.bodyX + trackingParams.headX + 25).*Pgrad;    


