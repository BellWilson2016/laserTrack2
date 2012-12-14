function calculateLatency(expN)


	showRaster = false;	

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

	figure();
	subplot(3,2,1);
	[n1,xout1] = hist(offLatency,min(offLatency):.002:max(offLatency));
	plot(xout1*1000,n1/max(n1),'b'); hold on;
	plot(xout1*1000,cumsum(n1)/sum(n1),'r');
	xlabel('Off latency (ms)'); ylabel('P');
	xlim([40 140]);
	subplot(3,2,2);
	[n2,xout2] = hist(onLatency,min(onLatency):.002:max(onLatency));	
	plot(xout2*1000,n2/max(n2),'b'); hold on;
	plot(xout2*1000,cumsum(n2)/sum(n2),'r');
	xlabel('On latency (ms)'); ylabel('P');
	xlim([40 140]);
	subplot(3,2,3);
	plot(transferForLast, offLatency*1000, 'b');
	xlabel('Time (s)');
	ylabel('Latency (ms)');
	xlim([0 transferTimes(end)]);	
	subplot(3,2,4);
	plot(transferForFirst, onLatency*1000, 'b');
	xlabel('Time (s)');
	ylabel('Latency (ms)');
	xlim([0 transferTimes(end)]);
	subplot(3,2,5);
	[n3, xout3] = hist(diff(transferTimes)*1000,0:2:200);
	plot(xout3,n3/max(n3),'b'); hold on;
	plot(xout3,cumsum(n3)/sum(n3),'r');
	xlim([0 140]);
	xlabel('Data transfer interval (ms)');
	subplot(3,2,6);
	intervals = diff(transferTimes);
	meanIntervals = smooth(intervals,181);
	plot(transferTimes(1:(end-1)),1./meanIntervals);
	xlabel('Time (s)');
	ylabel('Mean data transfer rate (Hz)');
	ylim([0 35]);
	lims = xlim();
	xlim([0 transferTimes(end)]);

	
	

if showRaster
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
end
	


