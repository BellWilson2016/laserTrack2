function correlateSerial()
    
    global transID;
    global fineDiffs;
    global frameCodes;
    global frameDiffs; 

	load('RTFW1.mat');

	% Pull video times, scale to seconds, starting at zero
	videoCodes = exp.epoch(1).track(:,5,1);
	videoTimes = exp.epoch(1).track(:,6,1);
	videoTimes = (videoTimes - videoTimes(1))*(24*60*60);
	
	% Pull the serial times, scale to seconds, starting at zero
	rawSerialCodes = exp.epoch(1).serialRecord(:,1);
	rawSerialTimes = exp.epoch(1).serialRecord(:,2);
	% Find data transmission codes
	ix = find( (rawSerialCodes >= hex2dec('24')) & (rawSerialCodes < (hex2dec('24') +  64)));
	serialCodes = rawSerialCodes(ix) - hex2dec('24');
	serialTimes = rawSerialTimes(ix);
	serialTimes = serialTimes - serialTimes(1);
	% Fix time wrapping
	ix = 0;
	while (size(ix,1) > 0 )
		% Find any negative jumps
		ix = find(diff(serialTimes) < 0);
		if (size(ix,1) > 0)
			firstWrappedTime = ix(1)+1;
			% Add a full cycle to all times after a negative nump
			serialTimes(firstWrappedTime:end) = serialTimes(firstWrappedTime:end) + 16*10^6;
		end
	end
	serialTimes = serialTimes./(16*10^6); % Scale to seconds

	% For each tranmission code, find the closest video time for each serial time
	% Scatter plot the difference
	% Fit it to a linear model
	allVideoTimes = [];
	allSerialTimes = [];
	for code = 0:63
		vIx = find(videoCodes == code);
		sIx = find(serialCodes == code);
		vT = videoTimes(vIx);
		sT = serialTimes(sIx);
		% Find the closest video time to each serial time
		ix = dsearchn(vT,sT);
		allVideoTimes  = [allVideoTimes;vT(ix)];
		allSerialTimes = [allSerialTimes;sT];
	end
	timeFit = fit(allSerialTimes,allVideoTimes,'poly1','Robust','Bisquare');
	disp(['Clock speed: ',num2str(timeFit.p1,8),' Clock offset: ',num2str(timeFit.p2,8)]);
	scatter(allVideoTimes,allSerialTimes - allVideoTimes,'b.'); hold on;
	plot([0:60], [0:60] - timeFit([0:60])','r');
	xlabel('Time (s)');
	ylabel('Serial Clock - Video Clock (s)');


    
    
        
% 	plot(scSer.Time,scSer.Data,'b'); hold on;
% 	plot(scVid.Time,scVid.Data,'r');
