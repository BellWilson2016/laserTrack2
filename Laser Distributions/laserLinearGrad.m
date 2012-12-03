function returnPower = laserLinearGrad(args)  

	global trackingParams;

    leftP  = args(1);
    rightP = args(2);

	Pgrad = (rightP - leftP)/50;  		% Power units / mm
    xPos = trackingParams.bodyX;
	
	returnPower = leftP + (xPos + 25).*Pgrad;    


