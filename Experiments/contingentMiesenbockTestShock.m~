function contingentMiesenbockTestShock()

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'contingentMisenbockTestShock'];
    exp.genotype       = 'NorpA[7]/y ; H134R / Or67d-Gal4 ; + / +';
    exp.flyAge         = 7;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;        % mL/side
	exp.laserPowers    = [45,0];
	exp.laserFilter    = 1;
	exp.nReps          = 8;	

	exp.protocol	 = @laser_cont_testshock_Miesenbock;
	exp.protocolArgs = {@laserFlatHalves, exp.laserPowers};
	cmd = {@runLaserProtocol,exp};
	scheduleEvent(10, cmd);  

