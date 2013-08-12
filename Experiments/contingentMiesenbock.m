function contingentMiesenbock()

	global allScheduledEvents;
	allScheduledEvents = [];	% Clear existing schedule

	% Setup generic experimental info
	exp.experimentName = [datestr(now,'YYmmDD-HHMMss-'),'contingentMisenbock'];
    exp.genotype       = 'NorpA[7]/y ; H134R / Gr21a-Gal4 (Suh) ; + / +';
    exp.flyAge         = 5;    % Days
    exp.sex            = 'M';
    exp.odor           = 'none';
    exp.odorConc       = 0;          % log10
    exp.flowRate       = 1200;        % mL/side
	exp.laserPowers    = [40,0];
	exp.laserFilter    = 1;
	exp.nReps          = 8;	

	exp.protocol	 = @laser_cont_shock_Miesenbock;
	exp.protocolArgs = {@laserFlatHalves, exp.laserPowers};
	cmd = {@runLaserProtocol,exp};
	scheduleEvent(10, cmd);  

