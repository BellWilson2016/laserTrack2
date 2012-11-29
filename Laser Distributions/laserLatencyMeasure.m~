function returnPower = laserLatencyMeasure(args)

    global trackingParams;
    
    lp = 1;

    % If there are any tracked pixels
    if (nnz(trackingParams.numPixels) > 0)
        returnPower = [1,1,1,1,1,1,1,1]*lp;
    else
        returnPower = [1,1,1,1,1,1,1,1]*0;
    end