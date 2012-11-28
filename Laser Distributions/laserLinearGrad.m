function returnPower = laserLinearGrad(args)  

    global trackingParams;
    powerBounds = args;
    
    leftP  = powerBounds(1);
    rightP = powerBounds(2);
    
    LB = trackingParams.calPoints.leftBound(1);
    RB = trackingParams.calPoints.rightBound(1);
    if (trackingParams.trackHead)
        xPos = trackingParams.xPos + trackingParams.headX;
    else
        xPos = trackingParams.xPos;
    end

    lp = round((xPos - LB + 1).*(rightP - leftP)/(RB-LB) + leftP);

    returnPower = lp;