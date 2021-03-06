function thermoTaxis1() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'thermoTaxis1'];
    exp.genotype       = 'w[-] ; [CyO], Arista[-]';
    exp.flyAge         = 1;    % Days
    exp.sex            = 'F';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;       % mL/side
    exp.refSide        = [];		 % 1 is left, -1 is right
	exp.laserPowers    =  zeros(1,8);
	exp.redMultiplier  = 1;
	exp.redPowers      =  [0,16,32,64,128,256,512,1024];
	exp.opposingBlue   =  zeros(1,8);
	exp.opposingRed    =  zeros(1,8);
	exp.laserFilter    = 1;
	exp.nReps          = 8;
	exp.comment		   = '20 Hz';	
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

	
