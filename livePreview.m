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
function livePreview(obj,event,hImage) 
   
    global trackingParams;
    
        % Get timestamp for frame.
        tstampstr = event.Timestamp;
        % Get handle to text label uicontrol.
        ht = getappdata(hImage,'HandleToTimestampLabel');
        % Set the value of the text label.
        set(ht,'String',tstampstr);
        
        data  = event.Data;         % 8-bit, 480x640
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
        set(hImage, 'CData', frame);
end

    
        