function singleSideSeriesShort() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'singleSideSeriesShort'];
    exp.genotype       = 'NorpA[7]/y ; H134R / Ir40a-Gal4 ; TM2 or TM6 / +';
    exp.flyAge         = 6;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;       % mL/side
	exp.laserPowers =  [0,4,8,16,32,64,128,240];
	exp.laserFilter    = 1;
	exp.nReps          = 8;
	exp.comment		   = '20 Hz';	
	exp.acclimationTime = 1; % Hours

	nSched = 0;

	% One pass has each power versus 0 on each side; 
	onePass = [exp.laserPowers , zeros(1,size(exp.laserPowers,2)) ;...
		 		zeros(1,size(exp.laserPowers,2)) , exp.laserPowers];
	nSeq = size(exp.laserPowers,2)*2;
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
			scheduleEvent(exp.acclimationTime*(60*60) + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	
