function returnPower = laserLinearGrad(args)  

    global trackingParams;
    powerBounds = args;
    
    leftP  = powerBounds(1);
    rightP = powerBounds(2);
    
    LB = trackingParams.calPoints.leftBound(1);
    RB = trackingParams.calPoints.rightBound(1);

        xPos = trackingParams.xPix;


    lp = round((xPos - LB + 1).*(rightP - leftP)/(RB-LB) + leftP);

    returnPower = lp;
