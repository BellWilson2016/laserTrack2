function measureLatency()

	global trackingParams;
	
	latSpacing = .5;
	nMeasures = 50;
	
	setLaserDistribution({@laserLatencyMeasure,[]});
	disp('Set laser distribution to: @laserLatencyMeasure');

	trackingParams.latencyList = [];
	trackingParams.oldInvert = trackingParams.invert;
	trackingParams.invert = true;
	

	T = timer('ExecutionMode','fixedRate','Period',latSpacing,'TimerFcn', @triggerLaser, 'TasksToExecute', nMeasures);
	start(T);
	
	TF = timer('ExecutionMode','singleShot','StartDelay',latSpacing*(nMeasures+2),'TimerFcn', @finishLatency);
	start(TF);


	function triggerLaser(obj,event)

	global trackingParams;
	
	disp('Latency trig.');
	trackingParams.latencyMeasurePhase = 1;
	
function finishLatency(obj,event)

	global trackingParams;
	
	disp('Finishing up latency measurement.');
	trackingParams.invert = trackingParams.oldInvert;
	
	figure();
	hist(trackingParams.latencyList,[0:.005:.2]);
	xlabel('Latency (sec)'); ylabel('N');
