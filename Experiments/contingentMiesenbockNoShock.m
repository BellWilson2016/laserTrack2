function contingentMiesenbockNoShock()

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'contingentMisenbockNoShock'];
    exp.genotype       = 'NorpA[7]/y ; H134R / Or42b-Gal4 ; + / +';
    exp.flyAge         = 3;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;        % mL/side
	exp.laserPowers    = [240,0];
	exp.laserFilter    = 1;
	exp.nReps          = 8;	

	exp.protocol	 = @laser_cont_noshock_Miesenbock;
	exp.protocolArgs = {@laserFlatHalves, exp.laserPowers};
	cmd = {@runLaserProtocol,exp};
	scheduleEvent(10, cmd);  

