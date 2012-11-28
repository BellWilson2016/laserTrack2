function defineMultiArena()

    global trackingParams;


    % Arena geometry specification
    c2cDist = 2.5;      % cm
    c2VentDist = .8;    % cm
    laneWidthDist = .5; % cm
    lanePadding = 1.75;  % Fraction
    
    topVtoBotVDist = 7*c2cDist + 0*c2VentDist; 
    c2cFrac = c2cDist / topVtoBotVDist;
    c2VentFrac = c2VentDist / topVtoBotVDist;
    laneWidthFrac = laneWidthDist / topVtoBotVDist;
    
    spacingFraction = .8;
   
    showRawView();
        
    disp('Click lane 1 top vent');
    topVent = ginput(1);

    disp('Click lane 8 top vent');
    bottomVent = ginput(1);
    
    disp('Click left-bound');
    leftBound = ginput(1);
    disp('Click right-bound');
    rightBound = ginput(1);

    ySpanPx =  bottomVent(2) - topVent(2);
    c2cPx = c2cFrac * ySpanPx;
    c2VentPx = c2VentFrac * ySpanPx;
    laneWidthPx = laneWidthFrac*lanePadding*ySpanPx;
     
    for i=1:8
        reg(i,1) = round(leftBound(1));
        reg(i,2) = round(rightBound(1));
        laneCenter = topVent(2) + c2VentPx + (i-1)*c2cPx;      
        reg(i,3) = round(laneCenter - laneWidthPx/2);
        reg(i,4) = round(laneCenter + laneWidthPx/2);
        trackingParams.xPos(i) = leftBound(1) + 5; 
        trackingParams.yPos(i) = laneCenter; 
        trackingParams.headX(i) = trackingParams.headLength;
        trackingParams.headY(i) = 0;
        trackingParams.dXdT(i) = 0;
        trackingParams.dYdT(i) = 0;
    end
    
    % Remove old graphics
    for region=1:size(trackingParams.lastLine,2)
        delete(trackingParams.lastLine(region));
        delete(trackingParams.boundingBox(region));
    end
    
    % Initialize tracking regions
    nRegions = size(reg,1);
    for region = 1:nRegions
        trackingParams.lastLine(region) = line([0 0],[1 1]);  
        trackingParams.boundingBox(region) = line([0 0],[1 1]);
    end

    % Go live with the regions
    trackingParams.reg = reg;
      
    trackingParams.calPoints.leftBound = leftBound;
    trackingParams.calPoints.rightBound = rightBound;   
    trackingParams.calPoints.topVent = topVent;
    trackingParams.calPoints.bottomVent = bottomVent;
    
    showFlyView();
    


