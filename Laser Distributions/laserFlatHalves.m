%%
% Returns flat laser distributions on each half.
%
function returnPower = laserFlatHalves(args)  

    global trackingParams;   
    laserPowers = args;
    
    leftP  = laserPowers(1);
    rightP = laserPowers(2);
    

    xPos = trackingParams.bodyX + trackingParams.headX;
        
    lp = (xPos < 0).*leftP + (xPos >= 0).*rightP;

    returnPower = lp;
