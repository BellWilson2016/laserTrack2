function calibrateLaser()

    calibrationPower = 1;  % of 255
    averagingTime = 15;    % sec
    stdLimit = 5.5;        % For rejecting reflections
    nPixThresh = 2;
    A = ones(1,8);		   % Unit vector 8 wide
    
    global trackingParams;

    % Don't let the tracking program scan
    setScanMirrors(false);
    trackingParams.getStd = true; 
	trackingParams.calibrationSet = false;
    
    % Move the laser to center field
    % outputVxVy(2.5,2.5);
    % setLaser(false);
    
    % Set appropriate laser settings and tracking
    trackingParams.trackThresh = 110;
    trackingParams.invert = true;
    
    vcam(20000, 80);
	showRawView();
    outputPositions(A.*-1.5,A.*0,A.*calibrationPower*3,A.*0);
    disp('Click beam reflection zone');
    pts = jGinput(2);
    outputPositions(A.*0,A.*0,A.*0,A.*0);
    disp('Averaging out background');
    showAvgView;
    setAvg(true);
        pause(averagingTime);
    setAvg(false);
    
    % Set the running average high so points will never track here.
    trackingParams.runningAvg((pts(1,1):pts(2,1)),(pts(1,2):pts(2,2))) = 255;
    
    pause(2);
    showFlyView;
    
	%setColorSwitch(3*A);

    %% Generate a grid of points to fit to
    nStepsX = 10;
    nStepsY = 25;
    minVx = -3.5;
    maxVx = -1;
    minVy = -4;
    maxVy = 4;
    spanVx = maxVx - minVx;
    spanVy = maxVy - minVy;
    n=1;
    clear coords;
    for x = 1:nStepsX
        for y = 1:nStepsY
            vX = (x - 1)*spanVx/(nStepsX - 1) + minVx;
            vY = (y - 1)*spanVy/(nStepsY - 1) + minVy;
            outputPositions(A.*vX,A.*vY,A.*calibrationPower*1,A.*0);
            pause(.35);
            % Only record the position if the laser is in frame
            m = 0;
            while ((trackingParams.nPixels(1) < nPixThresh) && (m < 20))
                m = m + 1;
            end
            if trackingParams.nPixels(1) >  nPixThresh
                xStd = trackingParams.stdX(1);
                yStd = trackingParams.stdY(1);
                if (xStd > stdLimit) || (yStd > stdLimit)
                      disp(['Rejected - Xstd: ',num2str(xStd),' Ystd: ',num2str(yStd)]);
%                     
%                     disp('Click the spot center.');
%                     xY = ginput(1);
%                     coords(n,:) = [vX,vY,xY(1), xY(2)];
%                     n = n + 1;
                else
                    coords(n,:) = [vX, vY, trackingParams.xTarget(1),trackingParams.yTarget(1)];
                    n = n + 1;
                end
                % disp([vX, vY]);
            else
                disp(['Too few: ',num2str(trackingParams.nPixels(1))]);
            end
        end
    end
    
 
    %% Now make the fit
    
    Vx = coords(:,1);
    Vy = coords(:,2);
    Px = coords(:,3);
    Py = coords(:,4);

    fX = fit([Px,Py],Vx,'poly55');
    fY = fit([Px,Py],Vy,'poly55');
    disp(fX);
    disp(fY);
    
    figure(2);
    plot(Vx,Vy,'b.');
    hold on;
    plot(fX([Px,Py]),fY([Px,Py]),'ro');
    xlabel('Vx'); ylabel('Vy');
    title('Tracked spot in blue, fit spot in red.');
    
    %% Now test out the model    
    testInterval = 20;
    n=1;
    clear Tcoords;
    for x = testInterval:testInterval:(trackingParams.width-testInterval)
        for y = testInterval:testInterval:(trackingParams.height-testInterval)
            vX = fX([x,y]);
            vY = fY([x,y]);
            outputPositions(A.*vX,A.*vY,A.*calibrationPower*1,A.*0);
            pause(.35);
            % Only record the position if the laser is in frame
            if trackingParams.nPixels(1) >  nPixThresh
                xStd = trackingParams.stdX(1);
                yStd = trackingParams.stdY(1);
                if (xStd > stdLimit) || (yStd > stdLimit)
                    disp(['Rejected - Xstd: ',num2str(xStd),' Ystd: ',num2str(yStd)]);
%                     disp('Click the spot center.');
%                     xY = ginput(1);
%                     Tcoords(n,:) = [x,y,vX,vY,xY(1), xY(2)];
%                     n = n + 1;
                else
                    Tcoords(n,:) = [x,y,vX, vY, trackingParams.xTarget(1),trackingParams.yTarget(1)];
                    n = n + 1;
                end
            else
                disp('Too Few!');
            end
        end
    end
            
    % Plot calibration test results
    figure(3);
    scatter(Tcoords(:,1),Tcoords(:,2),'b.');
    hold on;
    scatter(Tcoords(:,5),Tcoords(:,6),'ro');
    xlabel('Px');ylabel('Py');
    title('Predicted spot in blue, tracked in red.');
    xlim([0 trackingParams.width]); ylim([0 trackingParams.height]);
    
    figure(4); 
    subplot(2,1,1);
    % Xerror vs. X
    plot(Tcoords(:,1),Tcoords(:,1)-Tcoords(:,5),'.b'); hold on;
    % Yerror vs. X
    plot(Tcoords(:,1),Tcoords(:,2)-Tcoords(:,6),'.r'); 
    xlabel('X Coord (px)');
    ylabel('Residual (px)');
    subplot(2,1,2);
    % Xerror vs. Y
    plot(Tcoords(:,2),Tcoords(:,1)-Tcoords(:,5),'.r'); hold on;
    % Yerror vs. Y
    plot(Tcoords(:,2),Tcoords(:,2)-Tcoords(:,6),'.b');
    xlabel('Y Coord (px)');
    ylabel('Residual (px)');
    
    %% Turn laser off
    outputPositions(A.*0,A.*0,A.*0,A.*0);         
    
    % Save calibration data   
    save('laserCal.mat','fX','fY');
    trackingParams.calibrationSet = true;
    
    
    
    
    
    
    
    
    
