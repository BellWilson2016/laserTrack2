%%
% This function outputs in terms of screen pixel position.
%
%
function transmissionID = outputPositions(xPos,yPos,powers)

    global trackingParams;
	global gridDeviation;

%	xPos(6) = 169 + gridDeviation.x;
%	yPos(6) = 430 + gridDeviation.y;
%	xPos(6)
%	yPos(6)

    if (trackingParams.calibrationSet)  
        xV = trackingParams.laserCal.fX([xPos',yPos']);
        yV = trackingParams.laserCal.fY([xPos',yPos']);
    else
        xV = zeros(8,1);
        yV = zeros(8,1);
    end


    transmissionID = updateScanDriver(xV',yV',powers);
