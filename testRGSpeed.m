function testRGSpeed(nTimes, pauseTime)

	RG = reGen('Dev1');
	RG.setupTiming();
	RG.start();

	outVec = 1:8;
	latList = [];
	buffList = [];

	for n=1:nTimes
		
		pause(randi(pauseTime)/1000);
		%pause(pauseTime);
		
		tic;
		RG.updateOutput(mod(n,8).*ones(1,8) - 4,1:8,1:8,1:8);
		latList(end+1) = toc();
		
	end
		
	RG.stop();
	RG.clear()
	
	
	hist(latList, .001:.001:.200);

