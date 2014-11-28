function singleSideSeriesShortRB() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule
	
	listRecent(1);

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'singleSideSeriesShortRB'];
    exp.genotype       = 'NorpA[7]/y ; H134R / Or42a-Gal4 ; Or92a-Gal4 / +';
    exp.flyAge         = 8;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;          % mL/side
    exp.refSide        = [];		 % 1 is left, -1 is right
	exp.laserPowers    =  [0,2,4,8,12,16,32,64];
	exp.redMultiplier  = 2.5;
	exp.redPowers      =  round(exp.redMultiplier*max(exp.laserPowers) - exp.redMultiplier.*exp.laserPowers);
	exp.opposingBlue   =  zeros(1,8);
	exp.opposingRed    =  round(exp.redMultiplier*max(exp.laserPowers).*ones(1,8));
	exp.laserFilter    = 1;
	exp.nReps          = 8;
	exp.comment		   = '20 Hz, red thermal compensation';	
	exp.acclimationTime = 1; % Hours

	nSched = 0;

	% One pass through unique stimuli
	onePass = [exp.laserPowers,    exp.opposingBlue;...
		 	   exp.opposingBlue,   exp.laserPowers;...
			   exp.redPowers,      exp.opposingRed;...
			   exp.opposingRed,    exp.redPowers;...
			   ones(1,8),          -1.*ones(1,8)];
			   
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
			exp.protocol	 = @laser_1_halfL_1;
			exp.protocolArgs = {@laserFlatHalvesBR, [blueL, blueR, redL, redR]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent(exp.acclimationTime*(60*60) + 15 + (3.5*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	disp(['Scheduled Experiment: ',exp.experimentName]);
	
	setBestLatency(false);

	
