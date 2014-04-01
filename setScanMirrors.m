function setScanMirrors(trueOrFalse)

    global trackingParams;
    A = ones(1,8);
    
    trackingParams.scanMirrors = trueOrFalse;
    
    pause(.1);
    
    if ~trueOrFalse
        outputPositions(A.*0,A.*0,A.*0,A.*0);
    end
    
