function singleSideSeries()


	lp = [0,5,10,15,20,25,30];
	nReps = 1;

	% One pass has each power versus 0 on each side;
	onePass = [lp , zeros(1,size(lp,2)) ; zeros(1,size(lp,2)) , lp];
	nSeq = size(lp,2)*2;

	nSched = 0;
	for repN = 1:nReps
		order = randperm(nSeq);
		for seqN = 1:nSeq
			powerL = onePass(1,order(seqN));
			powerR = onePass(2,order(seqN));
			cmd = ['runLaserProtocol(@laser_1_2L,@laserFlatHalves,[',...
					num2str(powerL),',',num2str(powerR),']);'];
			scheduleEvent(15 + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	
