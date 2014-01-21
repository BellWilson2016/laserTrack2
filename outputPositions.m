%%
% Converts positions to voltages, outputs to DAC.
%
function transmissionID = outputPositions(xPos, yPos, powersB, powersR)

    global trackingParams;
	global RG;

    if (trackingParams.calibrationSet)  
        xV = trackingParams.laserCal.fX([xPos',yPos']);
        yV = trackingParams.laserCal.fY([xPos',yPos']);
    else
        % Just leave it as is.
        xV = xPos;
        yV = yPos;
    end

	transmissionID = randi(64);
	if length(xV) ~=8
		xV = ones(1,8).*xV(1);
		yV = ones(1,8).*yV(1);
		powersB = ones(1,8).*powersB(1);
		powersR = ones(1,8).*powersR(1);
	end
	RG.updateOutput(xV, yV, powersB, powersR);

