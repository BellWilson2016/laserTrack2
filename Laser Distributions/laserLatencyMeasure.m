function [powB, powR] = laserLatencyMeasure(args)

    global trackingParams;
    
    lp = 100;

    powB = zeros(1,8);
    powR = zeros(1,8);
	if (trackingParams.latencyMeasurePhase == 1)
		powB(1:8) = lp;
		trackingParams.latencyMeasurePhase = 2;
		pause(randi(100)/100*.013) % Pause so we're not always at the same point in the phase
    	tic();  	
    elseif (trackingParams.latencyMeasurePhase == 2)
    	if nnz(trackingParams.nPixels) > 0
    		trackingParams.latencyList(end+1) = toc;
    		trackingParams.latencyMeasurePhase = 0;
    	else
    		powB(1:8) = lp;
    	end
    end
