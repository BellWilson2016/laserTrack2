function twoChoiceFreqSeries() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'twoChoiceFreqSeries'];
    exp.genotype       = 'NorpA[7]/y ; ChR2/+ ; ChR2/+';
    exp.flyAge         = 6;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;       % mL/side
	%exp.laserPowers    = [4,6,9,14,21,32,48,72];
	exp.laserPowers    = [0,.5,1,2,5,10,20,50]; % Work as frequencies in Hz
	exp.opposingPower  = 0;
	%exp.laserPowers    = [108,162];
	exp.laserFilter    = 1;
	exp.nReps          = 8;
	exp.comment		   = 'Freq. 2 choice, air from L only';	

	% One pass has each power versus 0 on each side;
	onePass = [exp.laserPowers , exp.opposingPower.*ones(1,size(exp.laserPowers,2)) ;...
		 		exp.opposingPower.*ones(1,size(exp.laserPowers,2)) , exp.laserPowers];
	nSeq = size(exp.laserPowers,2)*2;

	nSched = 0;
	for repN = 1:exp.nReps
		% Randomize the presentation order
		order = randperm(nSeq);
		for seqN = 1:nSeq
			powerL = onePass(1,order(seqN));
			powerR = onePass(2,order(seqN));
			% Setup the protocol, laser distribution, and arguments
			exp.protocol	 = @laser_1_halfL_1;
			exp.protocolArgs = {@laserFlatFreqHalves, [powerL, powerR]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent(5 + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	
