function calculateLatency(expN)

	loadData(expN);

	serialID = exp.wholeTrack.serialID.Data;
	serialTimes = exp.wholeTrack.serialID.Time;

	vidTrigs = find(serialID == hex2dec('64'));
	vidNoTrigs = find(serialID == hex2dec('65'));
	transfers = find((serialID > hex2dec('23')) & (serialID < hex2dec('64')));

	allTrigs  = find((serialID == hex2dec('64')) | (serialID == hex2dec('65')) );
	allTrigsID = serialID(allTrigs);
		lastTrigs = find((allTrigsID(1:(end-1)) == hex2dec('64')) & ...
						 (allTrigsID(2:(end))   == hex2dec('65')));
		firstTrigs = find((allTrigsID(1:(end-1)) == hex2dec('65')) & ...
						  (allTrigsID(2:(end))   == hex2dec('64'))) + 1;

	lastTrigTimes = serialTimes(allTrigs(lastTrigs));
	firstTrigTimes = serialTimes(allTrigs(firstTrigs));
	transferTimes = serialTimes(transfers);


	% Ensure values are paired
	while (lastTrigTimes(1) > firstTrigTimes(1))
		firstTrigTimes(1) = [];
	end
	nGaps = min([size(lastTrigTimes,1),size(firstTrigTimes,1)]);
	lastTrigTimes = lastTrigTimes(1:nGaps);
	firstTrigTimes = firstTrigTimes(1:nGaps);

	for gapN = 1:nGaps
		transferForLast(gapN)  = transferTimes(max(find(transferTimes < firstTrigTimes(gapN))));
		transferForFirst(gapN) = transferTimes(min(find(transferTimes > firstTrigTimes(gapN))));
	end

	offLatency = transferForLast' - lastTrigTimes;
	onLatency  = transferForFirst' - firstTrigTimes;

	subplot(2,1,1);
	hist(offLatency);
	subplot(2,1,2);
	hist(onLatency);	

	figure();

	
	h = quickRaster(0,1,serialTimes(vidTrigs)); hold on;
	set(h,'Color','g');
	h = quickRaster(0,1,serialTimes(vidNoTrigs));
	set(h,'Color','r');
	h = quickRaster(1,1.2,lastTrigTimes);
	set(h,'Color','m');
	h = quickRaster(1,1.2,firstTrigTimes);
	set(h,'Color','m');
	h = quickRaster(1.1,1.3,transferTimes);
	set(h,'Color','b');
	h = quickRaster(1.3,1.5,transferForLast);
	set(h,'Color','r');
	h = quickRaster(1.3,1.5,transferForFirst);
	set(h,'Color','g');
	


