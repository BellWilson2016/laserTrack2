% livePreview.m
%
% This is a video preview window function for previewing tracking data.
% This seems to run best if called by the tracking algoritm that is called
% by FramesAcquiredFcn, rather than implemented as a MATLAB video preview
% callback (called by UpdatePreviewWindowFcn).  The reason is that
% FramesAcquiredFcn is guaranteed to run on every frame.  This has 4 modes:
%
% 0 - RawView, just the raw video plus the graticule
% 1 - FlyView, highlights the tracked regions
% 2 - AvgView, shows the running avg. in cyan, new video in red
% 3 - DiffView, shows the difference from avg., hotter in red, colder in
% blue.
%
% All of these show the graticule and track location.  
% Click on the window to re-center the region of interest in the video.
% Shift-Click to set the region of interest to the center of the frame.
%
% JSB 11/2010
function livePreview(obj,event) 
   
    global trackingParams;
    
    % If we're being careful about the latency, don't display the live preview
    if trackingParams.bestLatency
    	return;
    end
    
    boxSize = 5;            % Size of bounding box to draw 
    
		
    % Draw annotations to the preview figure
    % This is a substantial load.
    set(0,'CurrentFigure',trackingParams.previewFigure);
    numRegions = size(trackingParams.reg,1);
    for regionN = 1:numRegions
        % Draw tracking box
        delete(trackingParams.lastLine(regionN));
        if trackingParams.trackHead
            trackingParams.lastLine(regionN) = patch(...
                trackingParams.xTarget(regionN) + [-trackingParams.headXpix(regionN), trackingParams.headXpix(regionN), NaN, ...
				-trackingParams.headYpix(regionN), trackingParams.headYpix(regionN),  NaN],...
                trackingParams.yTarget(regionN) + [-trackingParams.headYpix(regionN), trackingParams.headYpix(regionN), NaN, ...
				trackingParams.headXpix(regionN), -trackingParams.headXpix(regionN),  NaN],...
                'k','EdgeColor','w','EdgeAlpha',.5);
        else
            trackingParams.lastLine(regionN) = patch(...
                trackingParams.xTarget(regionN) + boxSize.*[0 0 NaN -1 1 NaN],...
                trackingParams.yTarget(regionN) + boxSize.*[-1 1 NaN 0 0 NaN],...
                'k','EdgeColor','w','EdgeAlpha',.5);
        end
    end
       
	% If there isn't an available frame, don't update the preview
	if (size(trackingParams.lastFrame,1) == 0)
		return;
	end
	frame = trackingParams.lastFrame;
       
    % Show tracking for the whole screen, but make sure
    % to do this AFTER live-tracking is output
    % This duplicates some work, but lowers latency
    if trackingParams.invert
        diffPix = frame - uint8(trackingParams.runningAvg);
    else
        diffPix = uint8(trackingParams.runningAvg) - frame;
    end
    trackingParams.redPix = (diffPix > trackingParams.trackThresh);
    
    % Update the running avg if necessary
    if trackingParams.updateAvg
        flyDecayN = 20*trackingParams.imageTau;
        trackingParams.runningAvg = trackingParams.runningAvg(:,:)*(flyDecayN - 1)...
        									/flyDecayN + double(frame)/flyDecayN;
    end
             

        % Get timestamp for frame.
        tstampstr = datestr(now,'HH:MM:SS.FFF');
        % Get handle to text label uicontrol.
        ht = getappdata(trackingParams.hImage,'HandleToTimestampLabel');
        % Set the value of the text label.
        set(ht,'String',tstampstr);
        
        data  = frame;
        runAvg = uint8(trackingParams.runningAvg);           
        if trackingParams.displayMode == 1
            % Fly-highlight view
            halfFrame = data/2;
            frame(:,:,1) = uint8((245*uint8(trackingParams.redPix)) + halfFrame);
            frame(:,:,2) =  halfFrame;
            frame(:,:,3) =  halfFrame;  
        elseif trackingParams.displayMode == 2
            % Avg. view, puts current in red, avg in cyan
            frame(:,:,1) = data;
            frame(:,:,2) = runAvg;
            frame(:,:,3) = runAvg;
        elseif trackingParams.displayMode == 3
            % Diff. view, puts hotter than avg. in red, colder in blue
            frame(:,:,1) = uint8(data - runAvg);
            frame(:,:,2) = 0;
            frame(:,:,3) = uint8(runAvg - data);           
        else
            % Raw view
            frame(:,:,1) = data;
            frame(:,:,2) = data;
            frame(:,:,3) = data;
        end        
              
        % Turn image upright
        frame = permute(frame,[2,1,3]);
        
        set(0,'CurrentFigure',trackingParams.previewFigure);
        set(trackingParams.hImage, 'CData', frame);
        
end

    
        
