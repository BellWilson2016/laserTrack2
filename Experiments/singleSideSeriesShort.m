function singleSideSeriesShort() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'singleSideSeriesShort'];
    exp.genotype       = 'NorpA[7]/y ; H134R / Or42b-Gal4 ; Or92a-Gal4 / +';
    exp.flyAge         = 10;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;       % mL/side
	%exp.laserPowers    = [2,3,5,7,11,16,24,36];
	%exp.laserPowers    = [4,6,9,14,21,32,48,72]*2;
	exp.laserPowers    = [0,4,6,9,14,21,32,48];
	%exp.laserPowers = [0, 9, 14, 21, 32, 48, 64, 96];
	%exp.laserPowers    = [108,162];
	exp.laserFilter    = 1;
	exp.nReps          = 2;
	exp.comment		   = '20 Hz';	

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
			exp.protocolArgs = {@laserFlatHalves, [powerL, powerR]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent(5 + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	
