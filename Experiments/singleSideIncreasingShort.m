function singleSideIncreasingShort() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'singleSideIncreasingShort'];
    exp.genotype       = 'NorpA[7]/y ; ChR2/+ ; ChR2/Or92a-Gal4';
    exp.flyAge         = 22;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;        % mL/side
	exp.laserPowers    = [48,0,8,16,32,48];
	exp.laserFilter    = .25;
	exp.nReps          = 8;	

	% One pass has each power versus 0 on each side;
	onePass = [exp.laserPowers , zeros(1,size(exp.laserPowers,2)) ;...
		 		zeros(1,size(exp.laserPowers,2)) , exp.laserPowers];

	nSched = 0;
	for stimN = 1:size(exp.laserPowers,2)
		nSeq = exp.nReps;
		oneBlock = [ones(1,nSeq).*exp.laserPowers(stimN),zeros(1,nSeq) ; ...
					  zeros(1,nSeq), ones(1,nSeq).*exp.laserPowers(stimN)];
		% Randomize the presentation order
		order = randperm(nSeq*2);
		for seqN = 1:(nSeq*2)
			powerL = oneBlock(1,order(seqN));
			powerR = oneBlock(2,order(seqN));
			% disp([num2str(powerL),' ',num2str(powerR)]);
			% Setup the protocol, laser distribution, and arguments
			exp.protocol	 = @laser_1_halfL_1;
			exp.protocolArgs = {@laserFlatHalves, [powerL, powerR]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent(5 + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
		% disp('-');
	end

	
