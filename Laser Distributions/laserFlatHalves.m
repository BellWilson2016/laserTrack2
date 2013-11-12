%%
% Returns flat laser distributions on each half.
%
function returnPower = laserFlatHalves(args)  

	global trackingParams;
    
    leftP  = args(1);
    rightP = args(2);
    
   returnPower = (trackingParams.bodyX + trackingParams.headX < 0).*leftP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightP;

%	returnPower = [0,0,0,0,1,0,0,0].*leftP;
%	returnPower = [1,1,1,1,1,1,1,1].*leftP;


