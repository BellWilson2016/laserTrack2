function calibrateLaser()

    calibrationPower = 3;  % of 255
    averagingTime = 15;    % sec
    stdLimit = 6;          % For rejecting reflections
    nPixThresh = 2;
    A = ones(1,8);
    
    global trackingParams;

    % Don't let the tracking program scan
    setScanMirrors(false);
    calibrationScanParameters();
    trackingParams.getStd = true; 
    
    % Move the laser to center field
    % outputVxVy(2.5,2.5);
    % setLaser(false);
    
    % Set appropriate laser settings and tracking
    trackingParams.trackThresh = 110;
    trackingParams.invert = true;
    
    laserCam();
    updateScanDriver(A.*-(2^13),A.*0,A.*calibrationPower*1);
    disp('Click beam reflection zone');
    pts = ginput(2);
    updateScanDriver(A.*-(2^13),A.*0,A.*calibrationPower*0);
    disp('Averaging out background');
    showAvgView;
    setAvg(true);
        pause(averagingTime);
    setAvg(false);
        zoneOut(pts);
        pause(2);
    showFlyView;
    

    %% Generate a grid of points to fit to
    nStepsX = 10;
    nStepsY = 25;
    minVx = -2^13*1.4;
    maxVx = -2^13*.4;
    minVy = -2^13*1.6;
    maxVy = 2^13*1.6;
    spanVx = maxVx - minVx;
    spanVy = maxVy - minVy;
    n=1;
    clear coords;
    for x = 1:nStepsX
        for y = 1:nStepsY
            vX = (x - 1)*spanVx/(nStepsX - 1) + minVx;
            vY = (y - 1)*spanVy/(nStepsY - 1) + minVy;
            updateScanDriver(A.*vX,A.*vY,A.*calibrationPower);
            pause(.35);
            % Only record the position if the laser is in frame
            m = 0;
            while ((trackingParams.numPixels(1) < nPixThresh) && (m < 20))
                m = m + 1;
            end
            if trackingParams.numPixels(1) >  nPixThresh
                xStd = trackingParams.xStd(1);
                yStd = trackingParams.yStd(1);
                if (xStd > stdLimit) || (yStd > stdLimit)
                      disp(['Rejected - Xstd: ',num2str(xStd),' Ystd: ',num2str(yStd)]);
%                     
%                     disp('Click the spot center.');
%                     xY = ginput(1);
%                     coords(n,:) = [vX,vY,xY(1), xY(2)];
%                     n = n + 1;
                else
                    coords(n,:) = [vX, vY, trackingParams.xPos(1),trackingParams.yPos(1)];
                    n = n + 1;
                end
                % disp([vX, vY]);
            else
                disp(['Too few: ',num2str(trackingParams.numPixels(1))]);
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
            updateScanDriver(A.*vX,A.*vY,A.*calibrationPower);
            pause(.35);
            % Only record the position if the laser is in frame
            if trackingParams.numPixels(1) >  nPixThresh
                xStd = trackingParams.xStd(1);
                yStd = trackingParams.yStd(1);
                if (xStd > stdLimit) || (yStd > stdLimit)
                    disp(['Rejected - Xstd: ',num2str(xStd),' Ystd: ',num2str(yStd)]);
%                     disp('Click the spot center.');
%                     xY = ginput(1);
%                     Tcoords(n,:) = [x,y,vX,vY,xY(1), xY(2)];
%                     n = n + 1;
                else
                    Tcoords(n,:) = [x,y,vX, vY, trackingParams.xPos(1),trackingParams.yPos(1)];
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
    xlabel('Coord (px)');
    ylabel('Residual (px)');
    subplot(2,1,2);
    % Xerror vs. Y
    plot(Tcoords(:,2),Tcoords(:,1)-Tcoords(:,5),'.r'); hold on;
    % Yerror vs. Y
    plot(Tcoords(:,2),Tcoords(:,2)-Tcoords(:,6),'.b');
    xlabel('Coord (px)');
    ylabel('Residual (px)');
    
    %% Turn laser off
    updateScanDriver(A.*0,A.*0,A.*0);            
    
    % Save calibration data   
    save('laserCal.mat','fX','fY');
    
    trackFly();
    
    
    
    
    
    
    