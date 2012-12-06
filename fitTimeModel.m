% All of the rawSerialTimes must contain valid time info and not wrap
% Both times should start at 0
function timeModel = fitTimeModel(videoID, videoTime, serialID, serialTime) 

	% Find serial data transmission codes
	ix = find( (serialID >= hex2dec('24')) & (serialID < (hex2dec('24') + 64)) );
	transSerialID = serialID(ix) - hex2dec('24');
	transSerialTime = serialTime(ix);

	% For each ID, find the closest video time for each serial time
	% Fit to a linear model
	allVideoTimes = [];
	allTransSerialTimes = [];
	for ID = 0:63
		vIx = find(videoID == ID);
		sIx = find(transSerialID == ID);
		vT = videoTime(vIx);
		sT = transSerialTime(sIx);
		% Find the closest video time to each serial time
		ix = dsearchn(vT,sT);
		allVideoTimes = [allVideoTimes; vT(ix)];
		allTransSerialTimes = [allTransSerialTimes; sT];
	end

	% Fit a linear time model
	timeModel = fit(allTransSerialTimes,allVideoTimes,'poly1',...
			'Robust','Bisquare','Normalize','on'...
			);
	disp(['Fit clock model - M: ',num2str(timeModel(1)-timeModel(0),8),...
		' B: ',num2str(timeModel(0),8)]);

