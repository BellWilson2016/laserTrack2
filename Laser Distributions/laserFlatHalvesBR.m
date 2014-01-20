%%
% Returns flat laser distributions on each half.
%
function [blueP, redP] = laserFlatHalvesBR(args)  

	global trackingParams;
    
    leftBP  = args(1);
    rightBP = args(2);
	leftRP = args(3);
	rightRP = args(4);
    
    blueP = (trackingParams.bodyX + trackingParams.headX < 0).*leftBP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightBP;
	redP = (trackingParams.bodyX + trackingParams.headX < 0).*leftRP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightRP;


