function loadLaserCal()

    global trackingParams;

    load('laserCal.mat');
    trackingParams.laserCal.fX = fX;
    trackingParams.laserCal.fY = fY;
    trackingParams.calibrationSet = true;
