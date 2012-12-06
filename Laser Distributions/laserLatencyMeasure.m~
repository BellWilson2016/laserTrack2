function returnPower = laserLatencyMeasure(X,Y,args)

    global trackingParams;
    
    lp = 1;

    % If there are any tracked pixels
    if (nnz(trackingParams.nPixels) > 0)
        returnPower = lp;
    else
        returnPower = 0;
    end
