% initTrackingParams.m
%
% Sets up initial tracking parameters for tracking algorithms.
% Also initializes variables.  Users shouldn't normally need to edit
% this file, except the starting boundingSize.
% 
% JSB 11/2010
function trackingParams = initTrackingParams()
   
    global trackingParams;

    trackingParams.previewFigure = figure();
    set(gcf,'Position',[1056         354         216         640]);
    trackingParams.width = 216;
    trackingParams.height = 640;

    trackingParams.runningAvg = zeros(trackingParams.width,trackingParams.height); 
    trackingParams.redPix     = zeros(trackingParams.width,trackingParams.height); 
    trackingParams.displayMode = 0;
    trackingParams.updateAvg = false;
    trackingParams.lastLine = line([0 0],[1 1]);
    
    trackingParams.maxPixels = 50;  % Throw out excess pixels to keep speed high
    trackingParams.numPixels = 0;
    % trackingParams.laserArming = [0, 90; -180, -90];
    trackingParams.scanMirrors = true;
    trackingParams.calibrationSet = false;
    trackingParams.trackThresh = 45;
    trackingParams.invert = false;
    trackingParams.getStd = false;
    trackingParams.laseredZoneFcn = {@laserOff,[]};
    trackingParams.abortFlag = false;
    trackingParams.intervalList = [];
    trackingParams.intervalsLeft = 0;
    
    trackingParams.trackHead = false;
    trackingParams.headLength = 1;    % In standard deviations 
    trackingParams.velWindow = 60;    % # of frames to look at velocity over

    
    trackingParams.recordingSerial = false;
    trackingParams.serialRecord = [];
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
    
    % Start the status monitor timer
    trackingParams.statusMonitorTimer = timer('ExecutionMode','fixedRate','Period',60,...
        'TimerFcn',@webUpdateTimerFcn, 'StartDelay',60);
    start(trackingParams.statusMonitorTimer);
    
    % Tracking Regions
    trackingParams.reg(1,:) = [5,...
                               trackingParams.width-5,...
                               5,...
                               trackingParams.height-5];
    nRegions = size(trackingParams.reg,1);
    for region = 1:nRegions
        trackingParams.xPos(region) = 1; trackingParams.yPos(region) = 1;       
        trackingParams.headX(region) = 1; trackingParams.headY(region) = 1;
        trackingParams.dXdT(region) = 0; trackingParams.dYdT(region) = 0;
        
        trackingParams.lastLine(region) = line([0 0],[1 1]);  
        trackingParams.boundingBox(region) = line([0 0],[1 1]);
    end
    
    tic;
    
   
