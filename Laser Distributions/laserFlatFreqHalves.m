%%
% Returns flat laser distributions on each half.
%
function returnPower = laserFlatFreqHalves(args)  

	global trackingParams;
    
    leftF  = args(1);
    rightF = args(2);

	leftP  = round(256 - 1./(.01.*leftF));
	rightP = round(256 - 1./(.01.*rightF));
    
    returnPower = (trackingParams.bodyX + trackingParams.headX < 0).*leftP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightP;


