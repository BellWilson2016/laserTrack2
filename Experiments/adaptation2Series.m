function adaptation2Series() 

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'adaptation2Series'];
    exp.genotype       = 'NorpA[7]/y ; H134R / Or83b-Gal4 ; +/+';
    exp.flyAge         = 7;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;           		% log10
    exp.flowRate       = 1200;        		% mL/side
	exp.laserPowers    = [16,64,240];    
	exp.adaptationDelays = [.5,2,4]; 		% Minutes
	exp.adaptationPower = 240;
	exp.laserFilter    = 1;
	exp.nReps          = 3;	
	exp.comment		   = '20 Hz';

	[powers, delays] = meshgrid(exp.laserPowers,exp.adaptationDelays);

	% One pass has each power versus 0 on each side;
	onePass = [[powers(:);zeros(length(powers(:)),1)],...
			   [zeros(length(powers(:)),1);powers(:)],...
			   [delays(:);delays(:)]];
	nSeq = size(onePass,1);

	nSched = 0;
	for repN = 1:exp.nReps
		% Randomize the presentation order
		order = randperm(nSeq);
		for seqN = 1:nSeq
			powerL = onePass(order(seqN),1);
			powerR = onePass(order(seqN),2);
			adaptDelay = onePass(order(seqN),3);
			adaptPower = exp.adaptationPower;
			% Setup the protocol, laser distribution, and arguments
			exp.protocol	 = @laser_adaptation2;
			exp.protocolArgs = {@laserFlatHalves, [powerL, powerR, adaptDelay, adaptPower]};
			cmd = {@runLaserProtocol,exp};
			scheduleEvent((60*60)*0 + 5 + (8*60)*nSched, cmd);  
			nSched = nSched + 1;
		end
	end



	
