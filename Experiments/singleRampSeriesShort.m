function singleRampSeriesShort() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'singleRampSeriesShort'];
    exp.genotype       = 'NorpA[7]/y ; ChR2/+ ; ChR2/Gr21a-Gal4 (BD)';
    exp.flyAge         = 11;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;        % mL/side
	exp.laserPowers    = [0,14,32,72];
	exp.laserFilter    = .25;
	exp.nReps          = 16;	

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
			exp.protocol	 = @laser_1_halfL_1;
			exp.protocolArgs = {@laserLinearGradient, [powerL, powerR]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent(5 + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	
