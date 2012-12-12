function singleSideSeries()

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYMMDD-HHmmss-'),'singleSideSeries'];
    exp.genotype       = 'NorpA7';
    exp.flyAge         = '?';    % Days
    exp.sex            = 'M+F';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 300;        % mL/side
	exp.laserPowers    = [0,5,10,15,20,25,30];
	exp.nReps          = 1;	

	% One pass has each power versus 0 on each side;
	onePass = [exp.laserPowers , zeros(1,size(exp.laserPowers,2)) ;...
		 		zeros(1,size(exp.laserPowers,2)) , exp.laserPowers];
	nSeq = size(exp.laserPowers,2)*2;

	nSched = 0;
	for repN = 1:exp.nReps
		% Randomize the presentation order
		order = randperm(nSeq);
		for seqN = 1:nSeq
			powerL = onePass(1,order(seqN));
			powerR = onePass(2,order(seqN));
			% Setup the protocol, laser distribution, and arguments
			exp.protocol	 = @laser_1_2L;
			exp.protocolArgs = {@laserFlatHalves, [powerL, powerR]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent(5 + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	
