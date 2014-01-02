%%
% Returns flat laser distributions on each half.
%
function returnPower = laserFlatHalvesBR(args)  

	global trackingParams;
    
    leftP  = args(1);
    rightP = args(2);
	leftColorSwitch = args(3);
	rightColorSwitch = args(4);
    
    returnPower = (trackingParams.bodyX + trackingParams.headX < 0).*leftP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightP;
    csArray     = (trackingParams.bodyX + trackingParams.headX < 0).*leftColorSwitch +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightColorSwitch;
    setColorSwitch(csArray);

%	returnPower = [0,0,0,0,0,1,0,0].*leftP;
%	returnPower = [1,1,1,1,1,1,1,1].*leftP;
