function define2DArena(varargin)

    global trackingParams;


    % Arena geometry specification (mm)
	tops = [0,50,105,155,0,0,0,0];
	centers = tops+19.5;
	height = 39;
	width = 60;
    lanePadding = 0;     % width to pad beyond lane
    topVtoBotVDist = tops(4)-tops(1);

   
    showRawView();

    % Remove old graphics
	for i=1:size(trackingParams.calMarks,2)
		delete(trackingParams.calMarks(i));
	end
	trackingParams.calMarks = [];

    
	if (nargin == 0) 
		disp('Click lane 1 top edge');
		topVent = jGinput(1); 
		disp('Click lane 4 top edge');
		bottomVent = jGinput(1); 
		disp('Click left-bound');
		leftBound = jGinput(1);
		disp('Click right-bound');
		rightBound = jGinput(1);
	elseif (nargin > 0)
		topVent = trackingParams.calPoints.topVent;
		bottomVent = trackingParams.calPoints.bottomVent;
		leftBound = trackingParams.calPoints.leftBound;
		rightBound = trackingParams.calPoints.rightBound;
		calPoint = varargin{1};
		calDir   = varargin{2};
		switch (calPoint)
			case 1
				topVent(2) = topVent(2) + calDir;
			case 2
				bottomVent(2) = bottomVent(2) + calDir;
			case 3
				leftBound(1) = leftBound(1) + calDir;
			case 4
				rightBound(1) = rightBound(1) + calDir;
		end
	end
	if (nargin > 2)
		showBoundingBox = varargin{3};
		showHalfAndCenter = varargin{4};
		showCalPoints = varargin{5};
	else
		showBoundingBox = true;
		showHalfAndCenter = true;
		showCalPoints = true;
	end

		trackingParams.calPoints.topVent = topVent;
		trackingParams.calPoints.bottomVent = bottomVent;
		trackingParams.calPoints.leftBound = leftBound;
		trackingParams.calPoints.rightBound = rightBound;

		if showCalPoints   
			trackingParams.calMarks(end+1) = line(topVent(1) + 10.*[-1 1],topVent(2) + [0 0],'Color',.5*[1 1 1]);
			trackingParams.calMarks(end+1) = line(bottomVent(1) + 10.*[-1 1],bottomVent(2) + [0 0],'Color',.5*[1 1 1]);
			trackingParams.calMarks(end+1) = line( leftBound(1) + [0 0],[1 trackingParams.height],'Color',.5*[1 1 1]);
			trackingParams.calMarks(end+1) = line( rightBound(1) + [0 0],[1 trackingParams.height],'Color',.5*[1 1 1]);
		end

    % Remove old graphics
    for region=1:size(trackingParams.lastLine,2)
        delete(trackingParams.lastLine(region));
    end

	% Lanes have pixel integer centers, and pixel integer half-widths
    ySpanPx =  bottomVent(2) - topVent(2);
	pxPerMM = ySpanPx/topVtoBotVDist;
	laneHalfWidthPx = round((height/2 + lanePadding)*pxPerMM);     
    for i=1:8
        reg(i,1) = round( leftBound(1));
        reg(i,2) = round(rightBound(1));
        laneCenter = round(topVent(2) + pxPerMM*centers(i));   
        reg(i,3) = laneCenter - laneHalfWidthPx;
        reg(i,4) = laneCenter + laneHalfWidthPx;
        trackingParams.xTarget(i) = leftBound(1) + 5; 
        trackingParams.yTarget(i) = laneCenter; 
        trackingParams.headXpix(i) = 0;
        trackingParams.headYpix(i) = 0;
		trackingParams.bodyX(i) = leftBound(1) + 5;
		trackingParams.bodyY(i) = laneCenter;
        trackingParams.headX(i) = 0;
        trackingParams.headY(i) = 0;
        trackingParams.dXdT(i) = 0;
        trackingParams.dYdT(i) = 0;
		trackingParams.power(i) = 0;
    end
	% Make sure these regions don't track
	for i=5:8
        reg(i,1) = 1;
        reg(i,2) = 2;
        reg(i,3) = 1;
        reg(i,4) = 2;
		trackingParams.xTarget(i) = 0;
		trackingParams.yTarget(i) = 0;
		trackingParams.headX(i) = 0;
		trackingParams.headY(i) = 0;
		trackingParams.bodyX(i) = 0;
		trackingParams.bodyY(i) = 0;
	end
    
reg
    
    % Initialize tracking regions
    nRegions = size(reg,1);
    for region = 1:nRegions
        trackingParams.lastLine(region) = line([0 0],[1 1]);  
		if showBoundingBox
		    trackingParams.calMarks(end+1) = line([reg(region,1), reg(region,2), ...
		        reg(region,2),reg(region,1),reg(region,1)],[reg(region,4), ...
		        reg(region,4),reg(region,3),reg(region,3),reg(region,4)]);
		end
	end

    % Go live with the regions
    trackingParams.reg = reg;
	trackingParams.pxPerMM = pxPerMM;
	trackingParams.laneCenterX = (rightBound(1) - leftBound(1))/2 + 1;
	trackingParams.laneCenterY = laneHalfWidthPx + 1;

	if showHalfAndCenter
		for rN = 1:8
			trackingParams.calMarks(end+1) = line( [reg(rN,1) + trackingParams.laneCenterX - 1,...
														reg(rN,1) + trackingParams.laneCenterX - 1],...
				  								   [reg(rN,3) reg(rN,4)],...
												 	'Color',.5*[1 1 1]);
			trackingParams.calMarks(end+1) = line( [reg(rN,1) reg(rN,2)],...
				 								   [reg(rN,3) + trackingParams.laneCenterY - 1, ...
 														reg(rN,3) + trackingParams.laneCenterY - 1],...
													'Color',.5*[1 1 1]);
		end
	end
    
    showFlyView();
    


