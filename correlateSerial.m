function correlateSerial()
    
    global transID;
    global fineDiffs;
    global frameCodes;
    global frameDiffs; 

	load('RTFW1.mat');

	frameTimes = exp.epoch(1).track(:,6,1);
	frameDiffs = (frameTimes(:) - frameTimes(1))*(24*60*60);
	
	frameCodes = exp.epoch(1).track(:,5,1);
	
	allSerial = exp.epoch(1).serialRecord;
	serialCodes = allSerial(:,1);
	serialTimes = allSerial(:,2);

	ix = find( (serialCodes >= hex2dec('24')) & (serialCodes < (hex2dec('24') +  64)));
	transID = serialCodes(ix) - hex2dec('24');
	fineTimes = serialTimes(ix);

	% Fix time wrapping
	fineDiffs = (fineTimes(:) - fineTimes(1));
	ix = 0;
	while (size(ix,1) > 0 )
		ix = find(diff(fineDiffs) < 0);
		if (size(ix,1) > 0)
			firstWrap = ix(1)+1;
			fineDiffs(firstWrap:end) = fineDiffs(firstWrap:end) + 16*10^6;
		end
	end
	

	fineDiffs = fineDiffs./(16*10^6); % Scale to seconds

    scale = 1; lag = -.14;
    v = [lag, scale];
    [v,fval,exitflag,output] = fminsearch(@alignment,v);
    
    bestLag = v(1);
    bestScale = v(2);
    disp(num2str(bestLag,10));
    disp(num2str(bestScale,10));
    
       
    serialSeries = timeseries(transID,fineDiffs*bestScale + bestLag);
    videoSeries  = timeseries(frameCodes,frameDiffs);  
    
    plot(serialSeries,'b');
    hold on;
    plot(videoSeries,'r');
    
    

    
    function score = alignment(v)

        interval = 1/(10^3);
        lag   = v(1);
        scale = v(2);

        global transID;
        global fineDiffs;
        global frameCodes;
        global frameDiffs;
    
        serialSeries = timeseries(transID,fineDiffs*scale + lag);
        videoSeries  = timeseries(frameCodes,frameDiffs);    
        [scSer, scVid] = synchronize(serialSeries, videoSeries, 'Uniform','Interval',interval);
        diffs = scSer.Data - scVid.Data;
        score = sum(diffs.*diffs);

    
    
        
% 	plot(scSer.Time,scSer.Data,'b'); hold on;
% 	plot(scVid.Time,scVid.Data,'r');
