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
function liveTrack(obj, event)

    global vid;
    global trackingParams;


    % If no frames were returned, abort
    if vid.FramesAvailable > 0
    	if trackingParams.measureFrameRate
    		trackingParams.frameLengthList(end+1) = toc();
    		tic();
    	end
   		allFrames = getdata(vid,vid.FramesAvailable);
%    	if trackingParams.latencyMeasurePhase == 2
%    		disp(['Skipped ',num2str(size(allFrames,4)-1),' frames']);
%    		toc
%    	end
		if (size(allFrames,4) > 1)
		%	disp(['Skipped ',num2str(size(allFrames,4)-1),' frames']);
		else
		%	fprintf('.');
		end
        frame = allFrames(:,:,:,end);
    else
        return;
    end


    % Get trackingParams   
    trackThresh = trackingParams.trackThresh;
    invert = trackingParams.invert;   
    reg = trackingParams.reg;    
	numRegions = size(reg,1);
    runAvg = trackingParams.runningAvg;
	lastXtarget = trackingParams.xTarget;
	lastYtarget = trackingParams.yTarget;
	lastHeadXpix = trackingParams.headXpix;
	lastHeadYpix = trackingParams.headYpix;

    % For each subregion
    % Nb: All this tracking math only takes about 1 ms
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
        
        
        % Only track on 2 or more positive pixels
		nPixels(regionN) = size(row,1);
    	if (nPixels(regionN) > 1)
            
            % If there are too many pixels, throw the rest out
            % This keeps speed up?
            if (size(row,1) > trackingParams.maxPixels)
                row = row(1:trackingParams.maxPixels);
                col = col(1:trackingParams.maxPixels);
				nPixels(regionN) = trackingParams.maxPixels;
            end
                   
			bodyXpix(regionN) = mean(col);
			bodyYpix(regionN) = mean(row);
            
			% Track the head if necessary
            if (trackingParams.trackHead)
                % Extract centroid direction
                C = cov([col,row]);
                [Vecs,D] = eig(C);
                Evals = diag(D);
                [C, maxIx] = max(Evals);
                % hDist = trackingParams.headLength*Evals(maxIx); % Don't do this, Evals vary widely
				hDist = trackingParams.headLength;
                % Choose the end closest to the last front
                head1 =  hDist.*Vecs(maxIx,:);
                head2 = -hDist.*Vecs(maxIx,:);
                dLast1 = (head1(1)-lastHeadXpix(regionN))^2 + (head1(2)-lastHeadYpix(regionN))^2;
                dLast2 = (head2(1)-lastHeadXpix(regionN))^2 + (head2(2)-lastHeadYpix(regionN))^2;
                if dLast1 <= dLast2
                    trackingParams.headXpix(regionN) = head1(1);
                    trackingParams.headYpix(regionN) = head1(2);
                else
                    trackingParams.headXpix(regionN) = head2(1);
                    trackingParams.headYpix(regionN) = head2(2);
                end

				trackingParams.xTarget(regionN)  =  bodyXpix(regionN) + trackingParams.headXpix(regionN) + reg(regionN,1) - 1;
				trackingParams.yTarget(regionN)  =  bodyYpix(regionN) + trackingParams.headYpix(regionN) + reg(regionN,3) - 1;
				trackingParams.bodyX(regionN) =  (bodyXpix(regionN) - trackingParams.laneCenterX)./trackingParams.pxPerMM;
				trackingParams.bodyY(regionN) = -(bodyYpix(regionN) - trackingParams.laneCenterY)./trackingParams.pxPerMM;
				trackingParams.headX(regionN) =  trackingParams.headXpix(regionN)./trackingParams.pxPerMM;
				trackingParams.headY(regionN) = -trackingParams.headYpix(regionN)./trackingParams.pxPerMM;


                % Calculate the speed, and flip if it's fast and negative
                trackingParams.dXdT(regionN) = (trackingParams.velWindow - 1)/...
												trackingParams.velWindow * trackingParams.dXdT(regionN);
                trackingParams.dYdT(regionN) = (trackingParams.velWindow - 1)/...
												trackingParams.velWindow * trackingParams.dYdT(regionN);
                trackingParams.dXdT(regionN) = trackingParams.dXdT(regionN) + ...
												1/trackingParams.velWindow * trackingParams.headXpix(regionN) *...
											    (trackingParams.xTarget(regionN) - lastXtarget(regionN));
                trackingParams.dYdT(regionN) = trackingParams.dYdT(regionN) + ...
												1/trackingParams.velWindow * trackingParams.headYpix(regionN) * ...
												(trackingParams.yTarget(regionN) - lastYtarget(regionN));
                smoothVel = trackingParams.dXdT(regionN) + trackingParams.dYdT(regionN);
                if (smoothVel < -1)
                    trackingParams.dXdT(regionN) = 0; trackingParams.dYdT(regionN) = 0;
                    trackingParams.headXpix(regionN) = -trackingParams.headXpix(regionN);
                    trackingParams.headYpix(regionN) = -trackingParams.headYpix(regionN);
			
                    disp(['Flipped fly head #',num2str(regionN)]);
                    % updateWebStatus(['Flipped fly head #',num2str(regionN)] , false)
                end

%		   		laserFcn = trackingParams.laseredZoneFcn{1};
%		   		laserArgs = trackingParams.laseredZoneFcn{2};
%				trackingParams.power(regionN) = laserFcn(trackingParams.bodyX(regionN) + ...
%														 trackingParams.headX(regionN),...
%														 trackingParams.bodyY(regionN) + ...
%													     trackingParams.headY(regionN),laserArgs);			

			else % If we're not tracking head...
				trackingParams.xTarget(regionN)  =  bodyXpix(regionN) + reg(regionN,1) - 1;
				trackingParams.yTarget(regionN)  =  bodyYpix(regionN) + reg(regionN,3) - 1;
				trackingParams.bodyX(regionN) =  (bodyXpix(regionN) - trackingParams.laneCenterX)./trackingParams.pxPerMM;
				trackingParams.bodyY(regionN) = -(bodyYpix(regionN) - trackingParams.laneCenterY)./trackingParams.pxPerMM;
				trackingParams.headX(regionN) =  0;
				trackingParams.headY(regionN) =  0;

%		   		laserFcn = trackingParams.laseredZoneFcn{1};
%		   		laserArgs = trackingParams.laseredZoneFcn{2};
%				trackingParams.power(regionN) = laserFcn(trackingParams.bodyX(regionN),trackingParams.bodyY(regionN),laserArgs);			
            end
            
			% Optionally get the std for X and Y
            if (trackingParams.getStd)
                trackingParams.stdX(regionN) = std(col);
                trackingParams.stdY(regionN) = std(row);
            end  
        end % End if pixels are found
    end  % End for each lane
	
	trackingParams.nPixels = nPixels;
	
	
	
	transmissionID = 0;
    % Once each subregion is tracked, output the result to the scan mirrors
    if (trackingParams.scanMirrors)
			% Get the powers
		   	laserFcn = trackingParams.laseredZoneFcn{1};
		   	laserArgs = trackingParams.laseredZoneFcn{2};
			[trackingParams.powerB, trackingParams.powerR] = laserFcn(laserArgs);
            % Output to the scanController
           transmissionID = outputPositions(trackingParams.xTarget,trackingParams.yTarget,...
           						trackingParams.powerB, trackingParams.powerR);
    end


    % Save the data, scale to lane origin and calibration size
    if (trackingParams.recording)

		sample = [	trackingParams.bodyX;
				  	trackingParams.bodyY;
					trackingParams.headX;
					trackingParams.headY;
					ones(1,8).*transmissionID;
					ones(1,8).*now              ];
			
	     %  Sample# Field# Fly#
        trackingParams.tempData(end+1,1:6,:) = sample;
    end
    
    trackingParams.lastFrame = frame;

end
