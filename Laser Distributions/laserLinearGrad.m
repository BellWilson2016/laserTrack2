function returnPower = laserLinearGrad(args)  

    global trackingParams;
    powerBounds = args;
    
    leftP  = powerBounds(1);
    rightP = powerBounds(2);

	Pgrad = (rightP - leftP)/50;  		% Power units / mm
    


    xPos = trackingParams.bodyX + trackingParams.headX;
	
	lp = round(leftP + (xPos + 25)*Pgrad);        

    returnPower = lp;

