%%
% Returns flat laser distributions on each half.
%
function [blueP, redP] = laserFlatHalvesBR(args)  

	global trackingParams;
    
    leftBP  = args(1); % Left  blue
    rightBP = args(2); % Right blue
	leftRP  = args(3); % Left  red
	rightRP = args(4); % Right red
    
    blueP = (trackingParams.bodyX + trackingParams.headX < 0).*leftBP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightBP;
	redP = (trackingParams.bodyX + trackingParams.headX < 0).*leftRP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightRP;


