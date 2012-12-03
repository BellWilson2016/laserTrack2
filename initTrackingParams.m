% initTrackingParams.m
%
% Sets up initial tracking parameters for tracking algorithms.
% Also initializes variables.  Users shouldn't normally need to edit
% this file, except the starting boundingSize.
% 
% JSB 11/2010
function trackingParams = initTrackingParams()
   
    global trackingParams;	% Tracking Params

	% Info for the preview figure
    trackingParams.previewFigure = figure();
    trackingParams.width  = 216;
    trackingParams.height = 640;

     % Info for the tracking routine
    trackingParams.updateAvg = false;
    trackingParams.runningAvg = zeros(trackingParams.width,trackingParams.height); 
	trackingParams.imageTau = 5;    % Image averaging time-constant (secs)
    trackingParams.redPix     = zeros(trackingParams.width,trackingParams.height); 
	trackingParams.trackThresh = 45;
    trackingParams.displayMode = 0;
    trackingParams.invert = false;
    trackingParams.maxPixels = 50;  % Throw out excess pixels to keep speed high
    trackingParams.getStd = false;
    trackingParams.trackHead = false;
    trackingParams.headLength = 4;    % In pixels
    trackingParams.velWindow = 60;    % # of frames to look at velocity over
	trackingParams.laneCenterX = 0;   % Lane centers (in pixels) - all lanes should be equally sized...
	trackingParams.laneCenterY = 0;

	% Regions in which to track each fly
    trackingParams.reg(1,:) = [5,trackingParams.width-5,5,trackingParams.height-5];
    for region = 1:size(trackingParams.reg,1)
	% Tracked info for each fly
		trackingParams.xTarget(region) = 1;	   % Position of tracked feature in pixel space
		trackingParams.yTarget(region) = 1;
		trackingParams.headXpix(region) = 0;   % Position of head (if detected) in pixels
		trackingParams.headYpix(region) = 0;
		trackingParams.headX(region) = 0;	   % Position of head (if detected) in mm
		trackingParams.headY(region) = 0;
		trackingParams.bodyX(region) = 1;	   % Position of body in mm
		trackingParams.bodyY(region) = 1;
		trackingParams.dXdT(region) = 0;	   % Tracked feature speed in head direction coordinates 
		trackingParams.dYdT(region) = 0;
		trackingParams.stdX(region) = 1;	   % Standard deviation for each fly
		trackingParams.stdY(region) = 1;
		trackingParams.nPixels(region) = 0;
		trackingParams.lastLine(region)    = line([0 0],[1 1]);
	end

	% Setup calibration marks
	trackingParams.calPoints = [];
	trackingParams.calMarks = [];


    % Video tracking data logging
	trackingParams.recording = false;
	trackingParams.tempData = [];	

	% Serial data logging
    trackingParams.recordingSerial = false;
    trackingParams.serialRecord = [];

	% Mirror temp safety
    trackingParams.scanMirrors = true;
    trackingParams.calibrationSet = false;
    trackingParams.laseredZoneFcn = {@laserOff,[]};
    trackingParams.tempFault = false;
    trackingParams.mirrorTemp = 0;
	   
    % Write a new status file if the old one is too big
    load('statusData.mat');
    if (size(messageList,1) < 1200)
        messageList{end+1,1} = datestr(now);
        messageList{end,2} = 'RTFW Started.';
    else
        messageList = {};
        messageList{1,1} = datestr(now);
        messageList{1,2} = 'RTFW Started.';
    end
    save('statusData.mat','messageList');  
    
    % Start a status monitor timer
    trackingParams.statusMonitorTimer = timer('ExecutionMode','fixedRate','Period',60,...
        'TimerFcn',@webUpdateTimerFcn, 'StartDelay',60);
    start(trackingParams.statusMonitorTimer);

	% Start a timer to measure frame intervals    
    trackingParams.intervalList = [];
    trackingParams.intervalsLeft = 0;



    
   
