%%
% This function outputs in terms of screen pixel position.
%
%
function transmissionID = outputPositions(xPos,yPos,powers)

    global trackingParams;
	global gridDeviation;

%	if ~isfield(trackingParams,'bias')
%		trackingParams.bias = 0;
%		trackingParams.goRight = true;
%	end

%	if trackingParams.bias < -5
%		trackingParams.goRight = true;	
%	elseif trackingParams.bias > 5
%		trackingParams.goRight = false;
%	end

%	if trackingParams.goRight
%		trackingParams.bias = trackingParams.bias + 1;
%	else
%	    trackingParams.bias = trackingParams.bias - 1;
%	end

	% xPos = 5*ones(1,8)*trackingParams.bias;



    if (trackingParams.calibrationSet)  
        xV = trackingParams.laserCal.fX([xPos',yPos']);
        yV = trackingParams.laserCal.fY([xPos',yPos']);
    else
        xV = zeros(8,1);
        yV = zeros(8,1);
    end


    transmissionID = updateScanDriver(xV',yV',powers);
