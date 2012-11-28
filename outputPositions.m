%%
% This function outputs in terms of screen pixel position.
%
%
function outputPositions(xPos,yPos,powers)

    global trackingParams;

    if (trackingParams.calibrationSet)  
        xV = trackingParams.laserCal.fX([xPos',yPos']);
        yV = trackingParams.laserCal.fY([xPos',yPos']);
    else
        xV = zeros(8,1);
        yV = zeros(8,1);
    end

    updateScanDriver(xV',yV',powers);