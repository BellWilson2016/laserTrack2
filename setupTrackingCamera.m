% setupTrackingCamera.m
% 
% This function sets up a video object with a region of interest.  
% It also sets up live-image tracking and preview.
% This seems to run best if the tracking algorithm is called
% by FramesAcquiredFcn, rather than implemented as a MATLAB video preview
% callback (called by UpdatePreviewWindowFcn).  The reason is that
% FramesAcquiredFcn is guaranteed to run on every frame.
%
% If you want to save video to disk, edit the LoggingMode property
% This outputs its videoinput object to facilitate recording...
%
% JSB 11/2010
function vid = setupTrackingCamera() 

    global trackingParams;
    global vid;
    trackingParams = initTrackingParams();
        
    % Sets up the video object
	warning('off','MATLAB:JavaEDTAutoDelegation');
    vid = videoinput('dcam',1,'F7_Y8_640x480_mode0');
	triggerconfig(vid,'hardware','risingEdge','externalTriggerMode0-Source0');
	set(vid,'FramesPerTrigger',1);
	set(vid,'TriggerRepeat',inf);
	set(vid,'FrameGrabInterval', 1);

    
    % Setup the camera
    vcam(6000, 80);

    % Use an ROI in Format 7
    % Note the image will be rotated 90 degrees
    xOffset = (480 - trackingParams.width)/2;
    set(vid,'ROIPosition',[0,xOffset,trackingParams.height,trackingParams.width]);
    	%% Note that in Format7 (variable frame size) internally triggered frame rate is 
    	% determined by the 1394 bus packet size. If we're triggering externally we want
    	% this to be as fast as possible.
    	%
		% BytesPerPacket:   FPS:  (This changes in external trigger mode!)
		% 	524 / 600		30
		%	704				40
		%	792				45
		%	884 / 920		50
		%	976				55
		%	1060			60
        set(vid.Source, 'BytesPerPacket',2724); 
        set(trackingParams.previewFigure, 'Name', 'Live video...', ...
            'Position',[1064, 336, trackingParams.width, trackingParams.height],'Resize','off','MenuBar', ...
            'none','CloseRequestFcn','haltVideo','Units','pixels');
          
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    
    % Create the axes and image for the video feed and timestamp
    axes('Position',[0 0 1 1]);

        hTextLabel = uicontrol('style','text','String','Timestamp', ...
            'Units','pixels', 'FontSize',8,'Position',[trackingParams.width-65 1 65 12]);

    nBands = 3;
    trackingParams.hImage = image(zeros(trackingParams.height,...
                                        trackingParams.width, nBands));
    set(gca, 'xlimmode','manual',...
        'ylimmode','manual',...
        'zlimmode','manual',...
        'climmode','manual',...
        'alimmode','manual');
    set(gca,'CLim',[0 1]);
    
    % Draw the graticule
    l1 = line([0 trackingParams.width], [1 1].*trackingParams.height/2,'Color','w');
    l2 = line([1 1].*trackingParams.width/2, [0 trackingParams.height],'Color','w');
    
    
    %%  Set up the update preview window function, and tracking function.
    % MATLAB seems not to poll the 1394 driver fast enough to get high frame rates,
    % so manually polling with the timer (set below) works better
    % setappdata(trackingParams.hImage,'UpdatePreviewWindowFcn',@livePreview);
    % set(vid,'FramesAcquiredFcn',@liveTrack);
    % set(vid,'FramesAcquiredFcnCount',1);    
    
    % Make handle to text label available to update function.
    setappdata(trackingParams.hImage,'HandleToTimestampLabel',hTextLabel);
    
    % Start the video running so tracking will continue
    start(vid);
    
    %% Create timers to poll for new frames for tracking, and to creat the live preview.
    trackingTimer = timer('ExecutionMode','fixedRate','BusyMode','drop','Period',.003,'TimerFcn',@liveTrack);
    start(trackingTimer);
    
    displayTimer = timer('ExecutionMode','fixedRate','BusyMode','drop','Period',.050,...
    					 'StartDelay',2,'TimerFcn',@livePreview);
    start(displayTimer);
    

     


    




