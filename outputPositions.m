%%
% This function outputs in terms of screen pixel position.
%
%
function transmissionID = outputPositions(xPos,yPos,powers)

    global trackingParams;
	global gridDeviation;

%	xPos(5) = 169 + gridDeviation.x;
%	yPos(5) = 360 + gridDeviation.y;
%	xPos(5)
%	yPos(5)

    if (trackingParams.calibrationSet)  
        xV = trackingParams.laserCal.fX([xPos',yPos']);
        yV = trackingParams.laserCal.fY([xPos',yPos']);
    else
        xV = zeros(8,1);
        yV = zeros(8,1);
    end


    transmissionID = updateScanDriver(xV',yV',powers);
