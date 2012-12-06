%%
% Returns flat laser distributions on each half.
%
function returnPower = laserFlatHalves(args)  

	global trackingParams;
    
    leftP  = args(1);
    rightP = args(2);
    
    returnPower = (trackingParams.bodyX + trackingParams.headX < 0).*leftP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightP;


