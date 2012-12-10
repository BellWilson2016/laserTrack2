function doubleSideSeries()

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYMMDD-HHmmss-'),'doubleSideSeries'];
    exp.genotype       = 'ChR-Ctrl';
    exp.flyAge         =  0;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 250;        % mL/side
	exp.laserPowers    = [0,5,10,15,20,25,30];
	exp.nReps          = 1;	

	onePass = [];
	% One pass has each power versus 0 on each side;
	for i=1:size(exp.laserPowers,2)
		for j=1:size(exp.laserPowers,2)
			onePass(1:2,end+1) = [exp.laserPowers(i),exp.laserPowers(j)];
		end
	end

	nSeq = size(onePass,2);

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
