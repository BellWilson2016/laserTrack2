function contingentMiesenbock()

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'contingentMisenbockReverse'];
    exp.genotype       = 'NorpA[7]/y ; H134R / Or7a-Gal4 ; + / +';
    exp.flyAge         = 4;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;        % mL/side
	exp.laserPowers    = [70,0];
	exp.laserFilter    = 1;
	exp.nReps          = 8;	

	exp.protocol	 = @laser_cont_shock_MiesenbockReverse;
	exp.protocolArgs = {@laserFlatHalves, exp.laserPowers};
	cmd = {@runLaserProtocol,exp};
	scheduleEvent(10, cmd);  

