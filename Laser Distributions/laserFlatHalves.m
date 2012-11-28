%%
% Returns flat laser distributions on each half.
%
function returnPower = laserFlatHalves(args)  

    global trackingParams;   
    laserPowers = args;
    
    leftP  = laserPowers(1);
    rightP = laserPowers(2);
    
    LB = trackingParams.calPoints.leftBound(1);
    RB = trackingParams.calPoints.rightBound(1);
    if (trackingParams.trackHead)
        xPos = trackingParams.xPos + trackingParams.headX;
    else
        xPos = trackingParams.xPos;
    end

            
    lp = leftP.*((xPos - LB + 1 - (RB - LB)/2) <= 0) + ...
         rightP.*((xPos - LB + 1 - (RB - LB)/2) >= 0);

    returnPower = lp;