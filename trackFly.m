function trackFly()

    global trackingParams;
    
    setScanParameters();
    trackingParams.getStd = false;
    trackingParams.trackThresh = 50;
    trackingParams.invert = false;
    
    mcam(15000);    
    showAvgView;
    setAvg(true);
    pause(5);
    setAvg(false);
    showFlyView;
    
    % Set tracking laser to fly
    loadLaserCal();
    setScanMirrors(true);
