%%
% Returns flat laser distributions on each half.
%
function [blueP, redP] = laserFlatHalvesBRO(args)  

	global trackingParams;
    
    leftBP  = args(1); % Left  blue
    rightBP = args(2); % Right blue
	leftRP  = args(3); % Left  red
	rightRP = args(4); % Right red
	
	hystMM = 2; % mm
	shiftMultiplier = .5;
	xShift = zeros(1,8);
	
	blueP = (trackingParams.bodyX + trackingParams.headX < 0).*leftBP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightBP;
	redP = (trackingParams.bodyX + trackingParams.headX < 0).*leftRP +...
			 (trackingParams.bodyX + trackingParams.headX >= 0).*rightRP;
	
	if leftBP > rightBP
		% left epoch, keep laser on left
		ix = find(((trackingParams.bodyX + trackingParams.headX) > 0) &...
		          ((trackingParams.bodyX + trackingParams.headX) < hystMM) & ...
		          (trackingParams.nPixels > 1));
		xShift(ix) = -(trackingParams.bodyX(ix) + trackingParams.headX(ix))*trackingParams.pxPerMM;
		trackingParams.xTarget = trackingParams.xTarget + shiftMultiplier*xShift;	
		
		blueP(ix) = leftBP;
		redP(ix) = leftRP;
					           
	elseif rightBP > leftBP
		% right epoch, keep laser on right
		ix = find(((trackingParams.bodyX + trackingParams.headX) < 0) &...
		          ((trackingParams.bodyX + trackingParams.headX) > -hystMM) & ...
		          (trackingParams.nPixels > 1));
		xShift(ix) = -(trackingParams.bodyX(ix) + trackingParams.headX(ix))*trackingParams.pxPerMM;
		trackingParams.xTarget = trackingParams.xTarget + shiftMultiplier*xShift;	
		
		blueP(ix) = rightBP;
		redP(ix) = rightRP;
	end
	
    



