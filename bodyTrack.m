% liveTrack.m
%
% This function is called by FramesAcquiredFcn on every video acquisition
% frame.  It tracks using 4 different trackModes:
% 
%
% By default this tracks white flies on a black bg.  Set invert=false to
% track a black fly on a white background.
%
% JSB 11/2012
function bodyTrack(obj, event)

    global vid;
    global trackingParams;
    
    % Get the most recent frame if multiple are available
    allFrames = getdata(obj,obj.FramesAvailable);
    % If no frames were returned, abort
    if size(allFrames,1) > 0
        frame = allFrames(:,:,:,end);
    else
        return;
    end
    
    % Tracking parameters    
    imageTau = 5;           % Image averaging time-constant (secs)
    trackThresh = trackingParams.trackThresh;
    invert = trackingParams.invert;
    boxSize = 3;            % Size of bounding box to draw    
    reg = trackingParams.reg;    
	numRegions = size(reg,1);
    runAvg = trackingParams.runningAvg;
    xPos = trackingParams.xPos;
    yPos = trackingParams.yPos;
    
    % For each subregion
	for regionN = 1:numRegions
        
        subFrame = frame(reg(regionN,1):reg(regionN,2),...
            reg(regionN,3):reg(regionN,4));
        subAvg   = uint8(runAvg(reg(regionN,1):reg(regionN,2),...
            reg(regionN,3):reg(regionN,4)));
        if invert
            diffPix = (subFrame - subAvg);            
        else 
            diffPix = (subAvg - subFrame);           
        end     
        [col,row] = find(diffPix > trackThresh);
        
        
        % Compute their mean as the centroid center,
    	% and copy the computed positions to the global space
    	if (size(row,1) > 1)
        	xPos(regionN) = mean(col) + reg(regionN,1) - 1;  
            yPos(regionN) = mean(row) + reg(regionN,3) - 1; 
                
            if (trackingParams.getStd)
                trackingParams.xStd(regionN) = std(col);
                trackingParams.yStd(regionN) = std(row);
            end
        	trackingParams.numPixels(regionN) = size(col,1);
        else    
            % Don't update the position, but note that no pixels were found
            trackingParams.numPixels(regionN) = 0;
        end
    end
    
    % Save to the global variables
    trackingParams.xPos = xPos;
    trackingParams.yPos = yPos;

    
    % Once each subregion is tracked, output the result to the scan mirrors
    if (trackingParams.scanMirrors)
            % Output to the scanController
           powers = feval(trackingParams.laseredZoneFcn{1},...
               trackingParams.laseredZoneFcn{2});
           outputPositions(xPos,yPos,powers);
    end
    
    % If we're looking at frame intervals, update the interval list
    if (trackingParams.intervalsLeft > 0)
        trackingParams.intervalList(end+1) = toc();
        trackingParams.intervalsLeft = trackingParams.intervalsLeft - 1;
        if (trackingParams.intervalsLeft == 0)
            N = hist(trackingParams.intervalList.*1000,0:1:120);
            trackingParams.otherFig = figure(); subplot(2,1,1);
            N = N ./ sum(N(:));
            plot(0:1:120,cumsum(N),'b'); hold on;
            plot(0:1:120,N,'r');
            xlabel('Frame interval (ms)');
            ylabel('P'); ylim([0 1]); xlim([0 120]);
            trackingParams.intervalList = [];
        end
    end
    tic();
    

    
    % Draw annotations to the preview figure
    set(0,'CurrentFigure',trackingParams.previewFigure);
    for regionN = 1:numRegions
        % Draw tracking box
        delete(trackingParams.lastLine(regionN));

            trackingParams.lastLine(regionN) = line([xPos(regionN)-boxSize, xPos(regionN)+boxSize, ...
                xPos(regionN)+boxSize, xPos(regionN)-boxSize,xPos(regionN)-boxSize],[yPos(regionN)+boxSize, ...
                yPos(regionN)+boxSize,yPos(regionN)-boxSize,yPos(regionN)-boxSize,yPos(regionN)+boxSize]);

        % Draw bounding box
        delete(trackingParams.boundingBox(regionN));
        trackingParams.boundingBox(regionN) = line([reg(regionN,1), reg(regionN,2), ...
            reg(regionN,2),reg(regionN,1),reg(regionN,1)],[reg(regionN,4), ...
            reg(regionN,4),reg(regionN,3),reg(regionN,3),reg(regionN,4)]);
    end
    
    
    % Show tracking for the whole screen, but make sure
    % to do this AFTER live-tracking is output
    % This duplicates some work, but lowers latency
    if invert
        diffPix = frame - uint8(runAvg);
    else
        diffPix = uint8(runAvg) - frame;
    end
    trackingParams.redPix = (diffPix > trackThresh);
    
    % Update the running avg if necessary
    if trackingParams.updateAvg
        % fps = get(obj.Source,'FrameRate');
        fps = '30';
        flyDecayN = str2num(fps)*imageTau;
        trackingParams.runningAvg = runAvg(:,:)*(flyDecayN - 1)/flyDecayN + double(frame)/flyDecayN;
    end
      
    
    % Call the preview window
    anEvent.Data = frame;
    tVec = event.Data.AbsTime;
    anEvent.Timestamp = [num2str(tVec(4),'%02.f'),':',num2str(tVec(5),'%02.f'),':',num2str(floor(tVec(6)),'%02i'),'.',num2str(floor((tVec(6)-floor(tVec(6)))*100),'%02i')];
    livePreview(obj, anEvent,trackingParams.hImage);
    

end
