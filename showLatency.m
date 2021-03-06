function showLatency(files)

	loadData(files);

	figure();
	for epochN = 1:exp.nEpochs
		subplot(exp.nEpochs+1,1,epochN);
		bodyX = exp.epoch(epochN).track.bodyX;
		hist(diff(bodyX.time),0:.001:.100);
		xlabel('Frame interval');
		ylabel('N');
	end

	subplot(exp.nEpochs+1,1,exp.nEpochs+1);
	bodyX = exp.wholeTrack.bodyX;
	hist(diff(bodyX.time),0:.001:.100);
	xlabel('Frame interval');
	ylabel('N');

