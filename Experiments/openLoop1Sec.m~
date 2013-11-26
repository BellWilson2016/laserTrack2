function openLoop1Sec() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'openLoop1Sec'];
    exp.genotype       = 'NorpA[7]/y ; H134R/Gr21a-Gal4 (Suh) ; ChR2/+';
    exp.flyAge         = 3;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 0;        % mL/side
	exp.laserPowers    = [0,60,120,240];
	exp.laserFilter    = 1;
	exp.nReps          = 20;	
	exp.comment		   = '20 Hz';	

	% One pass has each power versus 0 on each side;
	onePass = [exp.laserPowers , exp.laserPowers ;...
		 	   exp.laserPowers , exp.laserPowers  ];
	nSeq = size(exp.laserPowers,2)*2;

	nSched = 0;
	for repN = 1:exp.nReps
		% Randomize the presentation order
		order = randperm(nSeq);
		for seqN = 1:nSeq
			powerL = onePass(1,order(seqN));
			powerR = onePass(2,order(seqN));
			% Setup the protocol, laser distribution, and arguments
			exp.protocol	 = @laser_15sec_1secL_15sec;
			exp.protocolArgs = {@laserFlatHalves, [powerL, powerR]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent(15 + (1*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end

	
