function singleSideSeriesShortRBCal() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'singleSideSeriesShort'];
    exp.genotype       = 'NorpA[7]/y ; H134R / + ; + / +';
    exp.flyAge         = 7;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;       % mL/side
	exp.bluePower      = 64;
	exp.laserPowers =  [0,32,48,64,96,128,160,192];
	exp.laserFilter    = 1;
	exp.nReps          = 8;
	exp.comment		   = '20 Hz - Long Pulses';	
	exp.acclimationTime = 4; % Hours

	nSched = 0;
	blueOn = 1;
	redOn  = 2;


	% One pass has each power versus 0 on each side; 
	onePass = [exp.bluePower.*ones(1,size(exp.laserPowers,2)),  exp.laserPowers;...
		 	   exp.laserPowers, exp.bluePower.*ones(1,size(exp.laserPowers,2));...
			   blueOn.*ones(1,size(exp.laserPowers,2)), redOn.*ones(1,size(exp.laserPowers,2));...
			    redOn.*ones(1,size(exp.laserPowers,2)),blueOn.*ones(1,size(exp.laserPowers,2))];

	nSeq = size(exp.laserPowers,2)*2;
	for repN = 1:exp.nReps
		% Randomize the presentation order
		order = randperm(nSeq);
		for seqN = 1:nSeq
			powerL = onePass(1,order(seqN));
			powerR = onePass(2,order(seqN));
			csL    = onePass(3,order(seqN));
			csR    = onePass(4,order(seqN));
			% Setup the protocol, laser distribution, and arguments
			exp.protocol	 = @laser_1_halfL_1;
			exp.protocolArgs = {@laserFlatHalvesBR, [powerL, powerR, csL, csR]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent(exp.acclimationTime*(60*60) + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	disp(['Scheduled Experiment: ',exp.experimentName]);

	
