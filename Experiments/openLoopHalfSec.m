function openLoopHalfSec() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule
	
	listRecent(1);

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'openLoopHalfSec'];
    exp.genotype       = 'NorpA[7] / y';
    exp.flyAge         = 2;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 0;       % mL/side
    exp.refSide        = [];		 % 1 is left, -1 is right
	exp.laserPowers    =  [0,64,256,1024];
	exp.redMultiplier  = 0;
	exp.redPowers      =  zeros(1,4);
	exp.opposingBlue   =  [0,64,256,1024];
	exp.opposingRed    =  zeros(1,4);
	exp.laserFilter    = 1;
	exp.nReps          = 16;
	exp.comment		   = '20 Hz, aristae removed';	
	exp.acclimationTime = 1; % Hours

	nSched = 0;

	% One pass through unique stimuli
	onePass = [exp.laserPowers,    exp.opposingBlue;...
		 	   exp.opposingBlue,   exp.laserPowers;...
			   exp.redPowers,      exp.opposingRed;...
			   exp.opposingRed,    exp.redPowers;...
			   ones(1,4),          -1.*ones(1,4)];
			   
	setBestLatency(true);		   

	nSeq = size(exp.laserPowers,2)*2;
	for repN = 1:exp.nReps
		% Randomize the presentation order
		order = randperm(nSeq);
		for seqN = 1:nSeq
			blueL = onePass(1,order(seqN));
			blueR = onePass(2,order(seqN));
			redL  = onePass(3,order(seqN));
			redR  = onePass(4,order(seqN));
			exp.refSide = onePass(5,order(seqN));
			% Setup the protocol, laser distribution, and arguments
			exp.protocol	 = @laser_OL_half_sec;
			exp.protocolArgs = {@laserFlatHalvesBR, [blueL, blueR, redL, redR]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent(exp.acclimationTime*(60*60) + 15 + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	disp(['Scheduled Experiment: ',exp.experimentName]);
	
	setBestLatency(false);

	
